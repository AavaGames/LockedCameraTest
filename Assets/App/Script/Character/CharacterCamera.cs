using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using TMPro;
using FishNet.Object;
using FishNet;
using GameKit.Utilities.Types;
using NaughtyAttributes;
using Assets.App.Script.Extensions;
using Assets.App.Script.Combat;
using Assets.App.Scripts.Character;
using System;
using UnityEngine.InputSystem;

namespace Assets.App.Script.Character
{
    public class CharacterCamera : NetworkBehaviour
    {
        public enum TargetSortingType { List, Distance }

        private ReticleController _reticleController;
        private Target _target;
        private PlayerInputController _input;

        [Foldout("Dependencies")]
        public GameObject followCameraPrefab;
        [Foldout("Dependencies")]
        public GameObject targetCameraPrefab;
        [Foldout("Dependencies")]
        public TextMeshProUGUI sortingLabel;

        [OnValueChanged("SetTargetingTypeThroughInspector")]
        public TargetSortingType targetSortingType;

        private bool _targeting = false;
        public bool Targeting => _targeting;
        private List<Target> validTargets = new List<Target>();
        private int _targetIndex = -1;
        private Target currentTarget;
        public Target CurrentTarget => currentTarget;
        private Transform previousTarget; // used for camera transition
        private float _targetDistance = 0f;
        public float TargetDistance => _targetDistance;

        private bool _targetFollowLockout = false;
        private float _targetFollowLockoutTime = 0.1f;
        private Coroutine _targetFollowLockoutCoroutine;

        [Header("Cameras")]
        public GameObject cameraFollow;

        public FloatRange cameraClamp = new FloatRange(-30f, 70f);
        [Tooltip("Additional degrees to override the camera. Useful for fine tuning camera position when locked")]
        public float cameraAngleOverride = 0.0f;
        [Tooltip("For locking the camera position on all axis")]
        public bool lockCameraPosition = false;

        private CinemachineVirtualCamera _followCamera;
        private CinemachineVirtualCamera[] _targetingCameras;
        private GameObject[] _cameraTargetFollows;
        private int _targetingCameraIndex = 0;
        private const int TARGETING_CAMERAS = 2;
        private CinemachineVirtualCamera _activeCamera;
        public CinemachineVirtualCamera ActiveCamera => _activeCamera;
        private Camera mainCamera;

        private float _cameraGoalPitch;
        private float _cameraGoalYaw;
        private const float LOOK_THRESHOLD = 0.01f;

        public Vector2 cameraFollowingSpeed = new Vector2(180, 180);

        private Action<InputAction.CallbackContext> targetAction;
        private Action<InputAction.CallbackContext> cycleTargetSortingAction;
        private Action<InputAction.CallbackContext> nextTargetAction;
        private Action<InputAction.CallbackContext> previousTargetAction;


        void Awake()
        {
            InstanceFinder.TimeManager.OnUpdate += TimeManager_OnUpdate;
            InstanceFinder.TimeManager.OnLateUpdate += TimeManager_OnLateUpdate;

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
                _reticleController = GetComponent<ReticleController>();
                _target = GetComponentInChildren<Target>();
                _input = GetComponent<PlayerInputController>();
                mainCamera = Camera.main;

                // Camera names are important for cinemachine blender settings
                _followCamera = Instantiate(followCameraPrefab).GetComponent<CinemachineVirtualCamera>();
                _followCamera.name = followCameraPrefab.name;
                _followCamera.Follow = cameraFollow.transform;


                _targetingCameras = new CinemachineVirtualCamera[TARGETING_CAMERAS];
                _cameraTargetFollows = new GameObject[TARGETING_CAMERAS];
                for (int i = 0; i < TARGETING_CAMERAS; i++)
                {
                    _targetingCameras[i] = Instantiate(targetCameraPrefab).GetComponent<CinemachineVirtualCamera>();
                    _targetingCameras[i].name = targetCameraPrefab.name;
                    _cameraTargetFollows[i] = new GameObject("CameraTargetFollow " + i.ToString());
                    _cameraTargetFollows[i].transform.parent = transform; // parent to character
                    _cameraTargetFollows[i].transform.localPosition = cameraFollow.transform.localPosition;
                    _targetingCameras[i].Follow = _cameraTargetFollows[i].transform;
                }
              
                ChangeCamera(_followCamera);

                SetCameraRotation(cameraFollow.transform.rotation.eulerAngles.y, cameraFollow.transform.rotation.eulerAngles.x);
                SetTargetingType(targetSortingType);

                targetAction = ctx => ToggleTargeting();
                cycleTargetSortingAction = ctx => CycleTargetSorting();
                nextTargetAction = ctx => FindTarget(true);
                previousTargetAction = ctx => FindTarget(false);

                _input.actions["Target"].performed += targetAction;
                _input.actions["CycleTargetSorting"].performed += cycleTargetSortingAction;
                _input.actions["NextTarget"].performed += nextTargetAction;
                _input.actions["PreviousTarget"].performed += previousTargetAction;

                gameObject.SetActive(true);
            }
        }

        public override void OnStopClient()
        {
            base.OnStopClient(); 

            if (IsOwner)
            {
                _input.actions["Target"].performed -= targetAction;
                _input.actions["CycleTargetSorting"].performed -= cycleTargetSortingAction;
                _input.actions["NextTarget"].performed -= nextTargetAction;
                _input.actions["PreviousTarget"].performed -= previousTargetAction;

                Destroy(_followCamera.gameObject);
                foreach (var obj in _targetingCameras) Destroy(obj.gameObject);
                foreach (var obj in _cameraTargetFollows) Destroy(obj.gameObject);
            }
        }

        public override void OnStartNetwork()
        {
            base.OnStartNetwork();
        }

        private void ToggleTargeting()
        {
            _targeting = !_targeting;

            if (currentTarget == null)
                FindTarget(true);

            CinemachineVirtualCamera cam;
            if (_targeting)
            {
                cam = _targetingCameras[_targetingCameraIndex];
                _targetFollowLockout = false;
                _reticleController.Show(targetSortingType == TargetSortingType.Distance);
            }
            else
            {
                cam = _followCamera;
                _reticleController.Hide();
            }

            ChangeCamera(cam);
        }

        private void CycleTargetSorting()
        {
            if (targetSortingType == TargetSortingType.Distance)
                SetTargetingType(TargetSortingType.List);
            else
                SetTargetingType(TargetSortingType.Distance);
        }

        void TimeManager_OnUpdate()
        {
            if (IsOwner)
            {

            }
        }

        private void TimeManager_OnLateUpdate()
        {
            if (IsOwner)
            {
                if (_targeting)
                {
                    // If target disconnects / disappears somehow
                    if (currentTarget == null)
                        FindTarget(true);

                    _targetDistance = Vector3.Distance(transform.position, currentTarget.transform.position);
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

        public void SetTargetingType(TargetSortingType type)
        {
            if (_targeting)
            {
                ChangeCamera(_followCamera);
                _targeting = false;
                _reticleController.Hide();
            }

            currentTarget = null;

            targetSortingType = type;

            sortingLabel.text = targetSortingType.ToString();
        }

        /// <summary>
        /// Callback on changing sorting type through inspector
        /// </summary>
        private void SetTargetingTypeThroughInspector()
        {
            SetTargetingType(targetSortingType);
        }    

        private void FindTarget(bool forward)
        {
            _targetFollowLockout = false;
            
            if (_target.hasNewTargets)
                validTargets = _target.GetTargets(false);

            if (validTargets.Count < 1)
            {
                Debug.LogWarning(gameObject.name + " has no valid targets");
                ToggleTargeting();
                return;
            }

            if (targetSortingType == TargetSortingType.List)
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
                    _targetIndex = IntExtension.WrapIndex(index, validTargets.Count);
                }
            }
            else if (targetSortingType == TargetSortingType.Distance)
            {
                List<float> distances = new List<float>(validTargets.Count);
                Vector3 pos = transform.position; // speeds up loop
                float currentTargetDistance = 0;

                for (int i = 0; i < validTargets.Count; i++)
                {
                    // Can be further optimized by skipping square root
                    float distance = Vector3.Distance(pos, validTargets[i].transform.position);
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

            if (currentTarget != null)
                previousTarget = currentTarget.transform;
            currentTarget = validTargets[_targetIndex];
            _targetingCameraIndex = IntExtension.WrapIndex(_targetingCameraIndex + 1, _targetingCameras.Length);
            _targetingCameras[_targetingCameraIndex].LookAt = currentTarget.transform;
        }

        private void ChangeCamera(CinemachineVirtualCamera cam)
        {
            cam.Priority = 10;
            cam.MoveToTopOfPrioritySubqueue();
            _activeCamera = cam;
        }

        private IEnumerator TargetFollowLockout()
        {
            _targetFollowLockout = true;
            yield return new WaitForSeconds(_targetFollowLockoutTime);
            _targetFollowLockout = false;
            _targetFollowLockoutCoroutine = null;
        }

        private void CameraRotation()
        {
            if (Cursor.lockState == CursorLockMode.Locked && !lockCameraPosition)
            {
                if (_input.look.sqrMagnitude >= LOOK_THRESHOLD)
                {
                    if (_targetFollowLockoutCoroutine != null)
                        StopCoroutine(_targetFollowLockoutCoroutine);
                    _targetFollowLockoutCoroutine = StartCoroutine(TargetFollowLockout());

                    // Controller doesnt seem to need delta either
                    //float deltaTimeMultiplier = _input.IsCurrentDeviceMouse ? 1.0f : Time.deltaTime;

                    float pitch = _cameraGoalPitch + _input.look.y;
                    float yaw = _cameraGoalYaw + _input.look.x;
                    SetCameraRotation(pitch, yaw);

                    ChangeCamera(_followCamera);
                }
                else if (_targeting && !_targetFollowLockout)
                {

                    if (previousTarget != null)
                        _cameraTargetFollows[IntExtension.WrapIndex(_targetingCameraIndex + 1, TARGETING_CAMERAS)].transform.LookAt(previousTarget);
                    _cameraTargetFollows[_targetingCameraIndex].transform.LookAt(currentTarget.transform);

                    // Smooth follow camera to target camera
                    var pitch = Mathf.MoveTowardsAngle(_cameraGoalPitch, _cameraTargetFollows[_targetingCameraIndex].transform.eulerAngles.x, cameraFollowingSpeed.x * Time.deltaTime);
                    var yaw = Mathf.MoveTowardsAngle(_cameraGoalYaw, _cameraTargetFollows[_targetingCameraIndex].transform.eulerAngles.y, cameraFollowingSpeed.y * Time.deltaTime);
                    SetCameraRotation(pitch, yaw);

                    ChangeCamera(_targetingCameras[_targetingCameraIndex]);
                }
            }

            cameraFollow.transform.rotation = Quaternion.Euler(_cameraGoalPitch + cameraAngleOverride, _cameraGoalYaw, 0.0f);
        }

        private void SetCameraRotation(float pitch, float yaw)
        {
            if (pitch > 180f) // fixes clamping issue
                pitch -= 360;

            _cameraGoalPitch = pitch;
            _cameraGoalYaw = yaw;

            _cameraGoalPitch = ClampAngle(_cameraGoalPitch, cameraClamp.Minimum, cameraClamp.Maximum);
            _cameraGoalYaw = ClampAngle(_cameraGoalYaw, float.MinValue, float.MaxValue);
        }

        private static float ClampAngle(float lfAngle, float lfMin, float lfMax)
        {
            if (lfAngle < -360f) lfAngle += 360f;
            if (lfAngle > 360f) lfAngle -= 360f;
            return Mathf.Clamp(lfAngle, lfMin, lfMax);
        }
    }
}