using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using StarterAssets;
using TMPro;
using FishNet.Object;
using UnityEngine.InputSystem.XR;
using UnityEngine.InputSystem;
using UnityEngine.Windows;
using Input = UnityEngine.Input;
using FishNet;

public class PlayerCameraController : NetworkBehaviour
{

    public GameObject followCameraPrefab;
    public GameObject targetCameraPrefab;

    public enum SortingType { List, Distance }

    private bool _targeting = false;
    public CinemachineVirtualCamera followCamera;
    public CinemachineVirtualCamera[] targetingCameras;
    private int currentTargetingCamera = 0;

    private PredictionMotor controller;

    public Targetable currentTarget;
    public List<Targetable> possibleTargets = new List<Targetable>();
    private int _targetIndex = -1;

    public UnityEngine.UI.Image Reticle;
    public TextMeshProUGUI distanceText;
    public TextMeshProUGUI sortingLabel;
    private float _targetDistance = 0f;
    public float TargetDistance => _targetDistance;

    private Targetable myTarget;
    private StarterAssetsInputs _input;
    private PlayerInput _playerInput;


    [Header("Variables")]
    public SortingType sortingType;
    [Tooltip("How high to position the camera above the player's feet/origin")]
    public float playerHeightOffset = 1.375f;
    public float cameraDistance = 3.0f;

    // cinemachine
    [Header("Cinemachine")]
    [Tooltip("The follow target set in the Cinemachine Virtual Camera that the camera will follow")]
    public GameObject CinemachineCameraTarget;

    [Tooltip("How far in degrees can you move the camera up")]
    public float TopClamp = 70.0f;

    [Tooltip("How far in degrees can you move the camera down")]
    public float BottomClamp = -30.0f;

    [Tooltip("Additional degress to override the camera. Useful for fine tuning camera position when locked")]
    public float CameraAngleOverride = 0.0f;

    [Tooltip("For locking the camera position on all axis")]
    public bool LockCameraPosition = false;

    private float _cinemachineTargetYaw;
    private float _cinemachineTargetPitch;
    private const float _threshold = 0.01f;

    private bool IsCurrentDeviceMouse
    {
        get
        {
            if (_playerInput == null) return false;

            return _playerInput.currentControlScheme == "KeyboardMouse";
        }
    }


    void Awake()
    {
        InstanceFinder.TimeManager.OnUpdate += TimeManager_OnUpdate;
        InstanceFinder.TimeManager.OnLateUpdate += TimeManager_OnLateUpdate;

        controller = transform.parent.GetComponent< PredictionMotor>();
        myTarget = transform.parent.GetComponentInChildren<Targetable>();
        Reticle.enabled = false;
        distanceText.enabled = false;

        gameObject.SetActive(false);
    }

    private void OnDestroy()
    {
        if (InstanceFinder.TimeManager != null)
        {
            InstanceFinder.TimeManager.OnUpdate -= TimeManager_OnUpdate;
            InstanceFinder.TimeManager.OnLateUpdate -= TimeManager_OnLateUpdate;
        }
    }

    public override void OnStartClient()
    {
        base.OnStartClient();

        if (base.IsOwner)
        {
            _playerInput = transform.parent.GetComponent<PlayerInput>();
            _playerInput.enabled = true;
            _input = transform.parent.GetComponent<StarterAssetsInputs>();

            // TODO move this naming elsewhere
            gameObject.name = "Player (" + ObjectId.ToString() + ")";

            followCamera = Instantiate(followCameraPrefab).GetComponent<CinemachineVirtualCamera>();
            targetingCameras = new CinemachineVirtualCamera[2];
            targetingCameras[0] = Instantiate(targetCameraPrefab).GetComponent<CinemachineVirtualCamera>();
            targetingCameras[1] = Instantiate(targetCameraPrefab).GetComponent<CinemachineVirtualCamera>();
            followCamera.Follow = CinemachineCameraTarget.transform;

            gameObject.SetActive(true);
        }
    }

    public override void OnStartNetwork()
    {
        base.OnStartNetwork();

        _cinemachineTargetYaw = CinemachineCameraTarget.transform.rotation.eulerAngles.y;
    }

    void TimeManager_OnUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            _targeting = !_targeting;

            if (currentTarget == null)
                FindTarget(true);

            CinemachineVirtualCamera cam;
            if (_targeting)
            {
                cam = targetingCameras[currentTargetingCamera];
            }
            else
            {
                CameraLookAt(currentTarget.transform);
                cam = followCamera;
            }
            Reticle.enabled = _targeting;
            if (sortingType == SortingType.Distance)
                distanceText.enabled = _targeting;
            ChangeCamera(cam);
        }

        if (Input.GetKeyDown(KeyCode.R))
        {
            if (_targeting)
            {
                CameraLookAt(currentTarget.transform);
                ChangeCamera(followCamera);
                _targeting = false;
                Reticle.enabled = false;
                distanceText.enabled = false;
            }

            currentTarget = null;

            if (sortingType == SortingType.Distance)
                sortingType = SortingType.List;
            else
                sortingType = SortingType.Distance;
        }

        sortingLabel.text = sortingType.ToString();
    }

    private void TimeManager_OnLateUpdate()
    {
        if (base.IsOwner)
        {
            if (_targeting)
            {
                if (Input.GetKeyDown(KeyCode.Alpha1))
                {
                    FindTarget(false);
                }
                else if (Input.GetKeyDown(KeyCode.Alpha3))
                {
                    FindTarget(true);
                }

                UpdateTargetingCameraPosition();
                _targetDistance = Vector3.Distance(transform.position, currentTarget.transform.position);
                distanceText.text = _targetDistance.ToString("#.00");
            }
            else
            {
                CameraRotation();
            }
        }
    }

    private void FindTarget(bool forward)
    {
        // TODO temporary targetable finder, rework into target manager
        possibleTargets = new List<Targetable>(FindObjectsOfType<Targetable>());
        foreach (Targetable targetable in possibleTargets)
        {
            if (targetable.gameObject == myTarget.gameObject)
            {
                possibleTargets.Remove(targetable);
                break;
            }
        }

        if (possibleTargets.Count < 1)
        {
            Debug.LogError("No targets in list");
            _targeting = false;
            return;
        }

        if (sortingType == SortingType.List)
        {
            if (_targetIndex == -1 || currentTarget == null)
            {
                _targetIndex = 0;
            }
            else
            {
                int index = _targetIndex;
                if (forward)
                    index++;
                else
                    index--;
                _targetIndex = WrapIndex(index, possibleTargets.Count);
            }
        }
        else if (sortingType == SortingType.Distance)
        {
            List<float> distances = new List<float>(possibleTargets.Count);
            Vector3 pos = transform.position; // speeds up loop
            float currentTargetDistance = 0;

            for (int i = 0; i < possibleTargets.Count; i++)
            {
                // Can be further optimized by skipping square root
                float distance = Vector3.Distance(pos, possibleTargets[i].transform.position);
                distances.Add(distance);

                if (i == _targetIndex)
                    currentTargetDistance = distance;
            }

            List<float> originalDistances = new List<float>(distances);
            distances.Sort();

            int index;
            if (_targetIndex == -1 || currentTarget == null)
            {
                index = 0;
            }
            else
            {
                // Find index of current target in sorted distances
                index = distances.IndexOf(currentTargetDistance); 
                if (forward)
                    index++;
                else
                    index--;
                index = WrapIndex(index, distances.Count);
            }
            // Find new target in the original index position
            _targetIndex = originalDistances.IndexOf(distances[index]);
        }

        currentTarget = possibleTargets[_targetIndex];
        // smooth quickly changing targets
        targetingCameras[currentTargetingCamera].transform.position = Camera.main.transform.position;
        currentTargetingCamera = WrapIndex(currentTargetingCamera + 1, targetingCameras.Length);
        ChangeCamera(targetingCameras[currentTargetingCamera]);
    }

    public float targetDistance;

    public int WrapIndex(int index, int arrayLength) 
    {
        if (index >= arrayLength)
        {
            index -= arrayLength;
            return WrapIndex(index, arrayLength);
        }
        else if (index < 0)
        {
            index += arrayLength;
            return WrapIndex(index, arrayLength);
        }
        return index;
    }

    private void ChangeCamera(CinemachineVirtualCamera cam)
    {
        cam.Priority = 10;
        cam.MoveToTopOfPrioritySubqueue();
    }


    private void UpdateTargetingCameraPosition()
    {
        var player = new Vector3(transform.position.x, transform.position.y + playerHeightOffset, transform.position.z);
        var target = currentTarget.transform.position;

        var heading = target - player;
        var distance = heading.magnitude;
        var direction = heading / distance; // This is now the normalized direction

        var position = player - (direction * cameraDistance);

        targetingCameras[currentTargetingCamera].LookAt = currentTarget.transform;
        targetingCameras[currentTargetingCamera].transform.position = position;
    }

    private void CameraRotation()
    {
        // if there is an input and camera position is not fixed
        if (_input.look.sqrMagnitude >= _threshold && !LockCameraPosition)
        {
            //Don't multiply mouse input by Time.deltaTime;
            float deltaTimeMultiplier = IsCurrentDeviceMouse ? 1.0f : Time.deltaTime;

            _cinemachineTargetYaw += _input.look.x * deltaTimeMultiplier;
            _cinemachineTargetPitch += _input.look.y * deltaTimeMultiplier;
        }

        // clamp our rotations so our values are limited 360 degrees
        _cinemachineTargetYaw = ClampAngle(_cinemachineTargetYaw, float.MinValue, float.MaxValue);
        _cinemachineTargetPitch = ClampAngle(_cinemachineTargetPitch, BottomClamp, TopClamp);

        // Cinemachine will follow this target
        CinemachineCameraTarget.transform.rotation = Quaternion.Euler(_cinemachineTargetPitch + CameraAngleOverride,
            _cinemachineTargetYaw, 0.0f);
    }

    public void CameraLookAt(Transform target)
    {
        CinemachineCameraTarget.transform.LookAt(target);
        _cinemachineTargetYaw = CinemachineCameraTarget.transform.rotation.eulerAngles.y;
        var pitch = CinemachineCameraTarget.transform.rotation.eulerAngles.x;
        if (pitch > 180f) // fixes clamping issue in CameraRotation()
            pitch -= 360;
        _cinemachineTargetPitch = pitch;
    }

    private static float ClampAngle(float lfAngle, float lfMin, float lfMax)
    {
        if (lfAngle < -360f) lfAngle += 360f;
        if (lfAngle > 360f) lfAngle -= 360f;
        return Mathf.Clamp(lfAngle, lfMin, lfMax);
    }
}
