using Assets.App.Scripts.Character;
using Cinemachine;
using FishNet;
using FishNet.Object;
using FishNet.Object.Prediction;
using FishNet.Transporting;
using NaughtyAttributes;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Assets.App.Scripts.Character
{
    public class CharacterMovement : NetworkBehaviour
    {
        [Header("Player")]
        [Tooltip("Move speed of the character in m/s")]
        public float moveSpeed = 3.5f;

        [Tooltip("How fast the character turns to face movement direction")]
        [Range(10f, 30f)]
        public float rotationSmoothSpeed = 12f;

        [Tooltip("Acceleration and deceleration")]
        public float speedChangeRate = 10.0f;

        [Space(10)]
        [Tooltip("The height the player can jump")]
        public float jumpHeight = 1.2f;

        [Tooltip("The character uses its own gravity value. The engine default is -9.81f")]
        public float gravity = -15.0f;
        public float terminalVelocity = 53.0f;

        [Space(10)]
        [Tooltip("Time required to pass before being able to jump again. Set to 0f to instantly jump again")]
        public float jumpTimeout = 0.50f;

        [Tooltip("Time required to pass before entering the fall state. Useful for walking down stairs")]
        public float fallTimeout = 0.15f;

        [Header("Player Grounded")]
        [Tooltip("If the character is grounded or not. Separate from CharacterController built in grounded check")]
        public bool grounded = true;

        [Tooltip("Useful for rough ground")]
        public float groundedOffset = -0.14f;

        [Tooltip("What layers the character uses as ground")]
        public LayerMask groundLayers;

        [Foldout("Audio")]
        public AudioClip landingAudioClip;
        [Foldout("Audio")]
        public AudioClip[] footstepAudioClips;
        [Foldout("Audio")]
        [Range(0, 1)] public float footstepAudioVolume = 0.5f;

        // player
        private float _targetRotation = 0.0f;
        private float _verticalVelocity = 0.0f;

        // timeout deltatime
        private float _jumpTimeoutTimer;
        private float _fallTimeoutTimer;

        // animation
        private float _animationBlend;
        private int _animIDSpeed;
        private int _animIDgrounded;
        private int _animIDJump;
        private int _animIDFreeFall;
        private int _animIDMotionSpeed;

        private Animator _animator;
        private CharacterController _controller;
        private PlayerInputController _input;
        private GameObject _mainCamera;

        private bool _hasAnimator;

        //MoveData for client simulation
        private MoveData _clientMoveData;

        //MoveData for replication
        public struct MoveData : IReplicateData
        {
            public Vector2 Move;
            public bool Jump;
            public float CameraEulerY;
            public bool Sprint;

            public void Dispose() { }
            private uint _tick;
            public uint GetTick() => _tick;
            public void SetTick(uint value) => _tick = value;
        }

        //ReconcileData for Reconciliation
        public struct ReconcileData : IReconcileData
        {
            public Vector3 position;
            public Quaternion rotation;
            public float verticalVelocity;
            public float fallTimeout;
            public float jumpTimeout;
            public bool grounded;

            public ReconcileData(Vector3 position, Quaternion rotation, float verticalVelocity, float fallTimeout, float jumpTimeout, bool grounded)
            {
                this.position = position;
                this.rotation = rotation;
                this.verticalVelocity = verticalVelocity;
                this.fallTimeout = fallTimeout;
                this.jumpTimeout = jumpTimeout;
                this.grounded = grounded;
                _tick = 0;
            }

            public void Dispose() { }
            private uint _tick;
            public uint GetTick() => _tick;
            public void SetTick(uint value) => _tick = value;
        }

        private void Awake()
        {
            InstanceFinder.TimeManager.OnTick += TimeManager_OnTick;
            InstanceFinder.TimeManager.OnUpdate += TimeManager_OnUpdate;

            _controller = GetComponent<CharacterController>();
        }

        private void OnDestroy()
        {
            if (InstanceFinder.TimeManager != null)
            {
                InstanceFinder.TimeManager.OnTick -= TimeManager_OnTick;
                InstanceFinder.TimeManager.OnUpdate -= TimeManager_OnUpdate;
            }
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            _controller.enabled = (IsServer || IsOwner);

            if (IsOwner)
            {
                _input = GetComponent<PlayerInputController>();
                _mainCamera = GameObject.FindGameObjectWithTag("MainCamera");
            }
        }

        public override void OnStartNetwork()
        {
            base.OnStartNetwork();

            _hasAnimator = TryGetComponent(out _animator);

            AssignAnimationIDs();

            // reset our timeouts on start
            _fallTimeoutTimer = fallTimeout;
            _jumpTimeoutTimer = jumpTimeout;
        }

        private void TimeManager_OnTick()
        {
            if (IsOwner)
            {
                Reconciliation(default, false);
                CheckInput(out MoveData md);
                Move(md, false);
            }
            if (IsServer)
            {
                Move(default, true);
                ReconcileData rd = new ReconcileData(transform.position, transform.rotation, _verticalVelocity, 
                    _fallTimeoutTimer, _jumpTimeoutTimer, grounded);
                Reconciliation(rd, true);
            }
        }

        private void TimeManager_OnUpdate()
        {
            if (IsOwner)
            {
                JumpAndGravity(_clientMoveData, Time.deltaTime);
                GroundedCheck();
                MoveWithData(_clientMoveData, Time.deltaTime);
            }
        }

        [Reconcile]
        private void Reconciliation(ReconcileData rd, bool asServer, Channel channel = Channel.Unreliable)
        {
            transform.position = rd.position;
            transform.rotation = rd.rotation;
            _verticalVelocity = rd.verticalVelocity;
            _fallTimeoutTimer = rd.fallTimeout;
            _jumpTimeoutTimer = rd.jumpTimeout;
            grounded = rd.grounded;
        }

        private void CheckInput(out MoveData md)
        {
            md = new MoveData()
            {
                Move = _input.move,
                Jump = _input.actions["MovementAbility"].IsPressed(),
                CameraEulerY = _mainCamera.transform.eulerAngles.y,
                Sprint = _input.actions["Sprint"].IsPressed(),
            };
        }

        [Replicate]
        private void Move(MoveData md, bool asServer, Channel channel = Channel.Unreliable, bool replaying = false)
        {
            if (asServer || replaying)
            {
                JumpAndGravity(md, (float)base.TimeManager.TickDelta);
                GroundedCheck();
                MoveWithData(md, (float)base.TimeManager.TickDelta);
            }
            else if (!asServer)
                _clientMoveData = md;
        }

        private void AssignAnimationIDs()
        {
            _animIDSpeed = Animator.StringToHash("Speed");
            _animIDgrounded = Animator.StringToHash("Grounded");
            _animIDJump = Animator.StringToHash("Jump");
            _animIDFreeFall = Animator.StringToHash("FreeFall");
            _animIDMotionSpeed = Animator.StringToHash("MotionSpeed");
        }

        private void GroundedCheck()
        {
            // set sphere position, with offset
            Vector3 spherePosition = new Vector3(transform.position.x, transform.position.y - groundedOffset,
                transform.position.z);
            grounded = Physics.CheckSphere(spherePosition, _controller.radius, groundLayers,
                QueryTriggerInteraction.Ignore);

            if (_hasAnimator)
                _animator.SetBool(_animIDgrounded, grounded);
        }

        private void MoveWithData(MoveData md, float delta)
        {
            float targetSpeed = moveSpeed;

            // a simplistic acceleration and deceleration designed to be easy to remove, replace, or iterate upon

            // note: Vector2's == operator uses approximation so is not floating point error prone, and is cheaper than magnitude
            if (md.Move == Vector2.zero) targetSpeed = 0.0f;

            _animationBlend = Mathf.Lerp(_animationBlend, targetSpeed, delta * speedChangeRate);
            if (_animationBlend < 0.01f) _animationBlend = 0f;

            Vector3 inputDirection = new Vector3(md.Move.x, 0.0f, md.Move.y).normalized;

            // note: Vector2's != operator uses approximation so is not floating point error prone, and is cheaper than magnitude
            if (md.Move != Vector2.zero)
            {
                _targetRotation = Mathf.Atan2(inputDirection.x, inputDirection.z) * Mathf.Rad2Deg + md.CameraEulerY;

                // rotate to face input direction relative to camera position
                transform.rotation = Quaternion.Slerp(transform.rotation, 
                    Quaternion.Euler(0.0f, _targetRotation, 0.0f),
                    rotationSmoothSpeed * delta);
            }

            Vector3 targetDirection = Quaternion.Euler(0.0f, _targetRotation, 0.0f) * Vector3.forward;

            // move the player
            _controller.Move(targetDirection.normalized * (targetSpeed * delta) +
                             new Vector3(0.0f, _verticalVelocity, 0.0f) * delta);

            if (_hasAnimator)
            {
                _animator.SetFloat(_animIDSpeed, _animationBlend);
                _animator.SetFloat(_animIDMotionSpeed, 1f);
            }
        }

        private void JumpAndGravity(MoveData md, float delta)
        {
            if (grounded)
            {
                _fallTimeoutTimer = fallTimeout;

                if (_hasAnimator)
                {
                    _animator.SetBool(_animIDJump, false);
                    _animator.SetBool(_animIDFreeFall, false);
                }

                // stop our velocity dropping infinitely when grounded
                if (_verticalVelocity < 0.0f)
                    _verticalVelocity = -2f;

                if (md.Jump && _jumpTimeoutTimer <= 0.0f)
                {
                    // the square root of H * -2 * G = how much velocity needed to reach desired height
                    _verticalVelocity = Mathf.Sqrt(jumpHeight * -2f * gravity);

                    if (_hasAnimator)
                        _animator.SetBool(_animIDJump, true);
                }

                if (_jumpTimeoutTimer >= 0.0f)
                    _jumpTimeoutTimer -= delta;
            }
            else
            {
                _jumpTimeoutTimer = jumpTimeout;

                if (_fallTimeoutTimer >= 0.0f)
                    _fallTimeoutTimer -= delta;
                else
                {
                    if (_hasAnimator)
                        _animator.SetBool(_animIDFreeFall, true);
                }
            }

            // apply gravity over time if under terminal (multiply by delta time twice to linearly speed up over time)
            if (_verticalVelocity < terminalVelocity)
            {
                _verticalVelocity += gravity * delta;
            }
        }

        private void OnDrawGizmosSelected()
        {
            if (Application.isPlaying)
            {
                Color transparentGreen = new Color(0.0f, 1.0f, 0.0f, 0.35f);
                Color transparentRed = new Color(1.0f, 0.0f, 0.0f, 0.35f);

                if (grounded) Gizmos.color = transparentGreen;
                else Gizmos.color = transparentRed;

                // when selected, draw a gizmo in the position of, and matching radius of, the grounded collider
                Gizmos.DrawSphere(
                    new Vector3(transform.position.x, transform.position.y - groundedOffset, transform.position.z),
                    _controller.radius);
            }
        }

        private void OnFootstep(AnimationEvent animationEvent)
        {
            if (!IsOwner) return;

            if (animationEvent.animatorClipInfo.weight > 0.5f)
            {
                if (footstepAudioClips.Length > 0)
                {
                    var index = Random.Range(0, footstepAudioClips.Length);
                    AudioSource.PlayClipAtPoint(footstepAudioClips[index], transform.TransformPoint(_controller.center), footstepAudioVolume);
                }
            }
        }

        private void OnLand(AnimationEvent animationEvent)
        {
            if (!IsOwner) return;

            if (animationEvent.animatorClipInfo.weight > 0.5f)
            {
                AudioSource.PlayClipAtPoint(landingAudioClip, transform.TransformPoint(_controller.center), footstepAudioVolume);
            }
        }
    }
}