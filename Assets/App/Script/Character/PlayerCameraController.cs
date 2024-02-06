using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using StarterAssets;
using TMPro;
using FishNet.Object;
using UnityEngine.InputSystem;
using Input = UnityEngine.Input;
using FishNet;
using GameKit.Utilities.Types;
using NaughtyAttributes;
using Assets.App.Script.Extensions;

namespace Assets.App.Script.Character
{
    public class PlayerCameraController : NetworkBehaviour
    {
        public enum SortingType { List, Distance }

        private Targetable _targetable;
        private StarterAssetsInputs _input;
        private PlayerInput _playerInput;

        [Foldout("Dependencies")]
        public GameObject followCameraPrefab;
        [Foldout("Dependencies")]
        public GameObject targetCameraPrefab;
        [Foldout("Dependencies")]
        public UnityEngine.UI.Image Reticle;
        [Foldout("Dependencies")]
        public TextMeshProUGUI distanceText;
        [Foldout("Dependencies")]
        public TextMeshProUGUI sortingLabel;

        [OnValueChanged("SetTargetingTypeThroughInspector")]
        public SortingType sortingType;
        [Tooltip("How high to position the target camera above the player's feet/origin")]
        public float playerHeightOffset = 1.375f;
        public float cameraDistance = 3.0f;

        private Targetable currentTarget;
        public Targetable CurrentTarget => currentTarget;
        private List<Targetable> possibleTargets = new List<Targetable>();
        private int _targetIndex = -1;
        private bool _targeting = false;
        private float _targetDistance = 0f;
        public float TargetDistance => _targetDistance;

        [Header("Cameras")]
        public GameObject cameraTarget;
        public FloatRange cameraClamp = new FloatRange(-30f, 70f);
        [Tooltip("Additional degrees to override the camera. Useful for fine tuning camera position when locked")]
        public float CameraAngleOverride = 0.0f;
        [Tooltip("For locking the camera position on all axis")]
        public bool LockCameraPosition = false;

        public CinemachineVirtualCamera followCamera;
        public CinemachineVirtualCamera targetingCamera;
        private CinemachineVirtualCamera _activeCamera;

        [SerializeField]
        [ReadOnly]
        private float _cameraGoalYaw;
        [SerializeField]
        [ReadOnly] 
        private float _cameraGoalPitch;
        private const float _threshold = 0.01f;

        public Vector2 cameraRotationSpeed = new Vector2(90, 90);

        private bool IsCurrentDeviceMouse
        {
            get
            {
                if (_playerInput == null) return false;
                return _playerInput.currentControlScheme == "KeyboardMouse"; // TODO update
            }
        }


        void Awake()
        {
            InstanceFinder.TimeManager.OnUpdate += TimeManager_OnUpdate;
            InstanceFinder.TimeManager.OnLateUpdate += TimeManager_OnLateUpdate;

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
                _targetable = transform.parent.GetComponentInChildren<Targetable>();
                _playerInput = transform.parent.GetComponent<PlayerInput>();
                _playerInput.enabled = true;
                _input = transform.parent.GetComponent<StarterAssetsInputs>();

                followCamera = Instantiate(followCameraPrefab).GetComponent<CinemachineVirtualCamera>();
                followCamera.Follow = cameraTarget.transform;
                targetingCamera = Instantiate(targetCameraPrefab).GetComponent<CinemachineVirtualCamera>();
                targetingCamera.Follow = cameraTarget.transform;
                ChangeCamera(followCamera);

                SetCameraRotation(cameraTarget.transform.rotation.eulerAngles.y, cameraTarget.transform.rotation.eulerAngles.x);
                SetTargetingType(sortingType);

                gameObject.SetActive(true);
            }
        }

        public override void OnStartNetwork()
        {
            base.OnStartNetwork();
        }

        void TimeManager_OnUpdate()
        {
            if (IsOwner)
            {
                if (Input.GetKeyDown(KeyCode.Tab))
                {
                    _targeting = !_targeting;

                    if (currentTarget == null)
                        FindTarget(true);

                    CinemachineVirtualCamera cam;
                    if (_targeting)
                        cam = targetingCamera;
                    else
                        cam = followCamera;

                    Reticle.enabled = _targeting;
                    if (sortingType == SortingType.Distance)
                        distanceText.enabled = _targeting;
                    ChangeCamera(cam);
                }

                if (Input.GetKeyDown(KeyCode.R))
                {
                    if (sortingType == SortingType.Distance)
                        SetTargetingType(SortingType.List);
                    else
                        SetTargetingType(SortingType.Distance);
                }

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
                }
            }
        }

        private void TimeManager_OnLateUpdate()
        {
            if (base.IsOwner)
            {
                if (_targeting)
                {
                    _targetDistance = Vector3.Distance(transform.position, currentTarget.transform.position);
                    distanceText.text = _targetDistance.ToString("#.00");
                }
                else
                {
                    
                }
            }
        }

        private void LateUpdate()
        {
            if (IsOwner)
            {
                CameraRotation();
            }
        }

        public void SetTargetingType(SortingType type)
        {
            if (_targeting)
            {
                ChangeCamera(followCamera);
                _targeting = false;
                Reticle.enabled = false;
                distanceText.enabled = false;
            }

            currentTarget = null;

            sortingType = type;

            sortingLabel.text = sortingType.ToString();
        }

        /// <summary>
        /// Callback on changing sorting type through inspector
        /// </summary>
        private void SetTargetingTypeThroughInspector()
        {
            SetTargetingType(sortingType);
        }    

        private void FindTarget(bool forward)
        {
            // TODO temporary targetable finder, rework into target manager
            possibleTargets = new List<Targetable>(FindObjectsOfType<Targetable>());
            foreach (Targetable targetable in possibleTargets)
            {
                if (targetable.gameObject == _targetable.gameObject)
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
                    _targetIndex = IntExtension.WrapIndex(index, possibleTargets.Count);
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
                    index = IntExtension.WrapIndex(index, distances.Count);
                }
                // Find new target in the original index position
                _targetIndex = originalDistances.IndexOf(distances[index]);
            }

            currentTarget = possibleTargets[_targetIndex];
        }

        private void ChangeCamera(CinemachineVirtualCamera cam)
        {
            cam.Priority = 10;
            cam.MoveToTopOfPrioritySubqueue();
            _activeCamera = cam;
        }

        private void CameraRotation()
        {
            // if there is an input and camera position is not fixed
            if (_input.look.sqrMagnitude >= _threshold && !LockCameraPosition)
            {
                //Don't multiply mouse input by Time.deltaTime;
                float deltaTimeMultiplier = IsCurrentDeviceMouse ? 1.0f : Time.deltaTime;

                float yaw = _cameraGoalYaw + _input.look.x * deltaTimeMultiplier;
                float pitch = _cameraGoalPitch + _input.look.y * deltaTimeMultiplier;
                SetCameraRotation(yaw, pitch);
            }
            else if (_targeting)
            {
                // move toward target

                var player = new Vector3(transform.position.x, transform.position.y + playerHeightOffset, transform.position.z);
                var target = currentTarget.transform.position;

                var heading = target - player;
                var distance = heading.magnitude;
                var direction = heading / distance; // This is now the normalized direction

                var goalRotation = Quaternion.LookRotation(direction).eulerAngles;

                var yaw = Mathf.MoveTowardsAngle(_cameraGoalYaw, goalRotation.y, cameraRotationSpeed.y * Time.deltaTime);
                var pitch = Mathf.MoveTowardsAngle(_cameraGoalPitch, goalRotation.x, cameraRotationSpeed.x * Time.deltaTime);

                SetCameraRotation(yaw, pitch);
            }

            cameraTarget.transform.rotation = Quaternion.Euler(_cameraGoalPitch + CameraAngleOverride, _cameraGoalYaw, 0.0f);
        }

        private void SetCameraRotation(float yaw, float pitch)
        {
            if (pitch > 180f) // fixes clamping issue
                pitch -= 360;

            _cameraGoalYaw = yaw;
            _cameraGoalPitch = pitch;

            // only when manual?
            _cameraGoalYaw = ClampAngle(_cameraGoalYaw, float.MinValue, float.MaxValue);
            _cameraGoalPitch = ClampAngle(_cameraGoalPitch, cameraClamp.Minimum, cameraClamp.Maximum);
        }

        public void FollowCameraLookAt(Transform target)
        {
            cameraTarget.transform.LookAt(target);
            _cameraGoalYaw = cameraTarget.transform.rotation.eulerAngles.y;
            var pitch = cameraTarget.transform.rotation.eulerAngles.x;
            if (pitch > 180f) // fixes clamping issue in CameraRotation()
                pitch -= 360;
            _cameraGoalYaw = pitch;
        }

        private static float ClampAngle(float lfAngle, float lfMin, float lfMax)
        {
            if (lfAngle < -360f) lfAngle += 360f;
            if (lfAngle > 360f) lfAngle -= 360f;
            return Mathf.Clamp(lfAngle, lfMin, lfMax);
        }
    }
}