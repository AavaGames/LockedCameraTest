using Assets.App.Scripts.Characters;
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

namespace Assets.App.Scripts.Characters
{
    public class CharacterMovement : NetworkBehaviour
    {
        [Header("Player")]
        public bool Active = true;

        [Tooltip("Move speed of the character in m/s")]
        public float MoveSpeed = 5.0f;

        [Tooltip("How fast the character turns to face movement direction")]
        [Range(10f, 30f)]
        public float RotationSmoothSpeed = 12f;

        [Space(10)]
        [Tooltip("The character uses its own gravity value. The engine default is -9.81f")]
        public float Gravity = -15.0f;

        public float TerminalVelocity = 53.0f;

        [Space(10)]
        [Tooltip("Time required to pass before being able to jump again. Set to 0f to instantly jump again")]
        public float JumpTimeout = 0.0f;

        [Tooltip("Time required to pass before entering the fall state. Useful for walking down stairs")]
        public float FallTimeout = 0.15f;

        [Header("Jumping")]
        public float JumpHeight = 2.0f;

        [Header("Player Grounded")]
        [Tooltip("If the character is grounded or not. Separate from CharacterController built in grounded check")]
        public bool Grounded = true;

        [Tooltip("Useful for rough ground")]
        public float GroundedOffset = -0.14f;

        [Tooltip("What layers the character uses as ground")]
        public LayerMask GroundLayers;

        [Foldout("Audio")]
        public AudioClip LandingAudioClip;
        [Foldout("Audio")]
        public AudioClip[] FootstepAudioClips;
        [Foldout("Audio")]
        [Range(0, 1)] public float FootstepAudioVolume = 0.5f;

        // player
        private float _targetRotation = 0.0f;
        private float _verticalVelocity = 0.0f;

        // timeout deltatime
        private float _jumpTimeoutTimer;
        private float _fallTimeoutTimer;

        [Header("Animation")]
        [Tooltip("Rate at which speed animation changes")]
        public float animSpeedChangeRate = 10.0f;
        private float _animationSpeedBlend;

        private int _animIDSpeed;
        private int _animIDgrounded;
        private int _animIDJump;
        private int _animIDFreeFall;
        private int _animIDMotionSpeed;

        private Animator _animator;
        private CharacterController _controller;
        private PlayerInputController _input;
        private GameObject _mainCamera;

        //MoveData for client simulation
        private MoveData _clientMoveData;

        //MoveData for replication
        public struct MoveData : IReplicateData
        {
            public bool Active;
            public Vector2 Move;
            public bool Jump;
            public float CameraEulerY;

            public void Dispose() { }
            private uint _tick;
            public uint GetTick() => _tick;
            public void SetTick(uint value) => _tick = value;
        }

        //ReconcileData for Reconciliation
        public struct ReconcileData : IReconcileData
        {
            public Vector3 Position;
            public Quaternion Rotation;
            public float VerticalVelocity;
            public float FallTimeout;
            public float JumpTimeout;
            public bool Grounded;

            public ReconcileData(Vector3 position, Quaternion rotation, float verticalVelocity, float fallTimeout, float jumpTimeout, bool grounded)
            {
                Position = position;
                Rotation = rotation;
                VerticalVelocity = verticalVelocity;
                FallTimeout = fallTimeout;
                JumpTimeout = jumpTimeout;
                Grounded = grounded;
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
            _animator = GetComponent<Animator>();
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

            AssignAnimationIDs();

            // reset our timeouts on start
            _fallTimeoutTimer = FallTimeout;
            _jumpTimeoutTimer = JumpTimeout;
        }

        #region Update

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
                    _fallTimeoutTimer, _jumpTimeoutTimer, Grounded);
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
            transform.position = rd.Position;
            transform.rotation = rd.Rotation;
            _verticalVelocity = rd.VerticalVelocity;
            _fallTimeoutTimer = rd.FallTimeout;
            _jumpTimeoutTimer = rd.JumpTimeout;
            Grounded = rd.Grounded;
        }

        private void CheckInput(out MoveData md)
        {
            md = new MoveData()
            {
                Move = _input.Move,
                Jump = _input.Actions["MovementAbility"].IsPressed(),
                CameraEulerY = _mainCamera.transform.eulerAngles.y,
            };
            md.Active = Active;
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

        #endregion

        public void Activate()
        {
            Active = true;
        }

        public void Deactivate()
        {
            Active = false;
        }

        /// <summary>
        /// Sets vertical velocity to 0, combined with Deactivate() to hover in the air
        /// </summary>
        public void ResetVerticalVelocity()
        {
            _verticalVelocity = 0f;
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
            Vector3 spherePosition = new Vector3(transform.position.x, transform.position.y - GroundedOffset,
                transform.position.z);
            Grounded = Physics.CheckSphere(spherePosition, _controller.radius, GroundLayers,
                QueryTriggerInteraction.Ignore);

            _animator.SetBool(_animIDgrounded, Grounded);
        }

        private void MoveWithData(MoveData md, float delta)
        {
            if (!md.Active)
                return;

            float targetSpeed = MoveSpeed;

            // a simplistic acceleration and deceleration designed to be easy to remove, replace, or iterate upon

            // note: Vector2's == operator uses approximation so is not floating point error prone, and is cheaper than magnitude
            if (md.Move == Vector2.zero) targetSpeed = 0.0f;

            _animationSpeedBlend = Mathf.Lerp(_animationSpeedBlend, targetSpeed, delta * animSpeedChangeRate);
            if (_animationSpeedBlend < 0.01f) _animationSpeedBlend = 0f;

            _animator.SetFloat(_animIDSpeed, _animationSpeedBlend);
            _animator.SetFloat(_animIDMotionSpeed, 1f);

            Vector3 inputDirection = new Vector3(md.Move.x, 0.0f, md.Move.y).normalized;

            // note: Vector2's != operator uses approximation so is not floating point error prone, and is cheaper than magnitude
            if (md.Move != Vector2.zero)
            {
                _targetRotation = Mathf.Atan2(inputDirection.x, inputDirection.z) * Mathf.Rad2Deg + md.CameraEulerY;

                // rotate to face input direction relative to camera position
                transform.rotation = Quaternion.Slerp(transform.rotation,
                    Quaternion.Euler(0.0f, _targetRotation, 0.0f),
                    RotationSmoothSpeed * delta);
            }

            Vector3 targetDirection = Quaternion.Euler(0.0f, _targetRotation, 0.0f) * Vector3.forward;

            // move the player
            _controller.Move(targetDirection.normalized * (targetSpeed * delta) +
                                new Vector3(0.0f, _verticalVelocity, 0.0f) * delta);
        }

        private void JumpAndGravity(MoveData md, float delta)
        {
            if (!md.Active)
                return;

            if (Grounded)
            {
                _fallTimeoutTimer = FallTimeout;

                _animator.SetBool(_animIDJump, false);
                _animator.SetBool(_animIDFreeFall, false);

                // stop our velocity dropping infinitely when grounded
                if (_verticalVelocity < 0.0f)
                    _verticalVelocity = -2f;

                if (md.Jump && _jumpTimeoutTimer <= 0.0f)
                {
                    // the square root of H * -2 * G = how much velocity needed to reach desired height
                    _verticalVelocity = Mathf.Sqrt(JumpHeight * -2f * Gravity);

                     _animator.SetBool(_animIDJump, true);
                }

                if (_jumpTimeoutTimer >= 0.0f)
                    _jumpTimeoutTimer -= delta;
            }
            else
            {
                _jumpTimeoutTimer = JumpTimeout;

                if (_fallTimeoutTimer >= 0.0f)
                    _fallTimeoutTimer -= delta;
                else
                {
                    _animator.SetBool(_animIDFreeFall, true);
                }
            }


            // apply gravity over time if under terminal (multiply by delta time twice to linearly speed up over time)
            if (_verticalVelocity < TerminalVelocity)
            {
                _verticalVelocity += Gravity * delta;
            }
        }

        private void OnDrawGizmosSelected()
        {
            if (Application.isPlaying)
            {
                Color transparentGreen = new Color(0.0f, 1.0f, 0.0f, 0.35f);
                Color transparentRed = new Color(1.0f, 0.0f, 0.0f, 0.35f);

                if (Grounded) Gizmos.color = transparentGreen;
                else Gizmos.color = transparentRed;

                // when selected, draw a gizmo in the position of, and matching radius of, the grounded collider
                Gizmos.DrawSphere(
                    new Vector3(transform.position.x, transform.position.y - GroundedOffset, transform.position.z),
                    _controller.radius);
            }
        }

        #region Animation Events

        private void OnFootstep(AnimationEvent animationEvent)
        {
            if (!IsOwner) return;

            if (animationEvent.animatorClipInfo.weight > 0.5f)
            {
                if (FootstepAudioClips.Length > 0)
                {
                    var index = Random.Range(0, FootstepAudioClips.Length);
                    AudioSource.PlayClipAtPoint(FootstepAudioClips[index], transform.TransformPoint(_controller.center), FootstepAudioVolume);
                }
            }
        }

        private void OnLand(AnimationEvent animationEvent)
        {
            if (!IsOwner) return;

            if (animationEvent.animatorClipInfo.weight > 0.5f)
            {
                AudioSource.PlayClipAtPoint(LandingAudioClip, transform.TransformPoint(_controller.center), FootstepAudioVolume);
            }
        }
        #endregion
    }
}