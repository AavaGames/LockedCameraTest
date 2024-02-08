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
using DG.Tweening;
using Assets.App.Script.Combat;
using Assets.App.Scripts.Character;
using System;

namespace Assets.App.Script.Character
{
    public class PlayerCameraController : NetworkBehaviour
    {
        public enum SortingType { List, Distance }

        private ReticleController _reticleController;
        private Target _target;
        private PlayerCharacterInput _input;

        [Foldout("Dependencies")]
        public GameObject followCameraPrefab;
        [Foldout("Dependencies")]
        public GameObject targetCameraPrefab;
        [Foldout("Dependencies")]
        public TextMeshProUGUI sortingLabel;

        [OnValueChanged("SetTargetingTypeThroughInspector")]
        public SortingType sortingType;
        [Tooltip("How high to position the target camera above the player's feet/origin")]
        public float playerHeightOffset = 1.375f;
        public float cameraDistance = 3.0f;

        private bool _targeting = false;
        public bool Targeting => _targeting;
        private List<Target> validTargets = new List<Target>();
        private int _targetIndex = -1;
        private Target currentTarget;
        public Target CurrentTarget => currentTarget;
        private float _targetDistance = 0f;
        public float TargetDistance => _targetDistance;

        private bool _targetFollowLockout = false;
        private float _targetFollowLockoutTime = 0.1f;
        private Coroutine _targetFollowLockoutCoroutine;


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
        public CinemachineVirtualCamera ActiveCamera => _activeCamera;
        private Camera mainCamera;

        [SerializeField]
        [ReadOnly] 
        private float _cameraGoalPitch;
        [SerializeField]
        [ReadOnly]
        private float _cameraGoalYaw;
        private const float _threshold = 0.01f;

        public Vector2 cameraRotationSpeed = new Vector2(90, 90);


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
                _input = GetComponent<PlayerCharacterInput>();
                mainCamera = Camera.main;

                followCamera = Instantiate(followCameraPrefab).GetComponent<CinemachineVirtualCamera>();
                followCamera.Follow = cameraTarget.transform;
                targetingCamera = Instantiate(targetCameraPrefab).GetComponent<CinemachineVirtualCamera>();
                targetingCamera.Follow = cameraTarget.transform;
                ChangeCamera(followCamera);

                SetCameraRotation(cameraTarget.transform.rotation.eulerAngles.y, cameraTarget.transform.rotation.eulerAngles.x);
                SetTargetingType(sortingType);

                _input.actions["Target"].performed += ctx => { ToggleTargeting(); };
                _input.actions["CycleTargetSorting"].performed += ctx => { CycleTargetSorting(); };
                _input.actions["NextTarget"].performed += ctx => { FindTarget(true); };
                _input.actions["PreviousTarget"].performed += ctx => { FindTarget(false); };

                gameObject.SetActive(true);
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
                cam = targetingCamera;
                _targetFollowLockout = false;
                _reticleController.Show(sortingType == SortingType.Distance);
            }
            else
            {
                cam = followCamera;
                _reticleController.Hide();
            }

            ChangeCamera(cam);
        }

        private void CycleTargetSorting()
        {
            if (sortingType == SortingType.Distance)
                SetTargetingType(SortingType.List);
            else
                SetTargetingType(SortingType.Distance);
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

        public void SetTargetingType(SortingType type)
        {
            if (_targeting)
            {
                ChangeCamera(followCamera);
                _targeting = false;
                _reticleController.Hide();
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
            _targetFollowLockout = false;
            
            if (_target.hasNewTargets)
                validTargets = _target.GetTargets(false);

            if (validTargets.Count < 1)
            {
                Debug.LogWarning(gameObject.name + " has no valid targets");
                ToggleTargeting();
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
                    _targetIndex = IntExtension.WrapIndex(index, validTargets.Count);
                }
            }
            else if (sortingType == SortingType.Distance)
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

            currentTarget = validTargets[_targetIndex];
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
            if (Cursor.lockState == CursorLockMode.Locked)
            {
                // if there is an input and camera position is not fixed
                if (_input.look.sqrMagnitude >= _threshold && !LockCameraPosition)
                {
                    if (_targetFollowLockoutCoroutine != null)
                        StopCoroutine(_targetFollowLockoutCoroutine);
                    _targetFollowLockoutCoroutine = StartCoroutine(TargetFollowLockout());

                    //Don't multiply mouse input by Time.deltaTime;
                    float deltaTimeMultiplier = _input.IsCurrentDeviceMouse ? 1.0f : Time.deltaTime;

                    float pitch = _cameraGoalPitch + _input.look.y;
                    float yaw = _cameraGoalYaw + _input.look.x;
                    SetCameraRotation(pitch, yaw);
                }
                else if (_targeting && !_targetFollowLockout)
                {
                    var player = new Vector3(transform.position.x, transform.position.y + playerHeightOffset, transform.position.z);
                    var target = currentTarget.transform.position;

                    var heading = target - player;
                    var distance = heading.magnitude;
                    var direction = heading / distance;

                    var goalRotation = Quaternion.LookRotation(direction).eulerAngles;

                    // TODO rework to a kind of tweener that uses easing
                    var pitch = Mathf.MoveTowardsAngle(_cameraGoalPitch, goalRotation.x, cameraRotationSpeed.x * Time.deltaTime);
                    var yaw = Mathf.MoveTowardsAngle(_cameraGoalYaw, goalRotation.y, cameraRotationSpeed.y * Time.deltaTime);

                    SetCameraRotation(pitch, yaw);
                }
            }

            cameraTarget.transform.rotation = Quaternion.Euler(_cameraGoalPitch + CameraAngleOverride, _cameraGoalYaw, 0.0f);
        }

        private void SetCameraRotation(float pitch, float yaw)
        {
            if (pitch > 180f) // fixes clamping issue
                pitch -= 360;

            _cameraGoalPitch = pitch;
            _cameraGoalYaw = yaw;

            // only when manual?
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