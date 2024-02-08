using Assets.App.Scripts.Character;
using Cinemachine;
using FishNet;
using FishNet.Object;
using FishNet.Object.Prediction;
using FishNet.Transporting;
using StarterAssets;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PredictionMotor : NetworkBehaviour
{
    [Header("Player")]
    [Tooltip("Move speed of the character in m/s")]
    public float MoveSpeed = 2.0f;

    [Tooltip("Sprint speed of the character in m/s")]
    public float SprintSpeed = 5.335f;

    [Tooltip("How fast the character turns to face movement direction")]
    [Range(10f, 30f)]
    public float RotationSmoothTime = 12f;

    [Tooltip("Acceleration and deceleration")]
    public float SpeedChangeRate = 10.0f;

    public AudioClip LandingAudioClip;
    public AudioClip[] FootstepAudioClips;
    [Range(0, 1)] public float FootstepAudioVolume = 0.5f;

    [Space(10)]
    [Tooltip("The height the player can jump")]
    public float JumpHeight = 1.2f;

    [Tooltip("The character uses its own gravity value. The engine default is -9.81f")]
    public float Gravity = -15.0f;

    [Space(10)]
    [Tooltip("Time required to pass before being able to jump again. Set to 0f to instantly jump again")]
    public float JumpTimeout = 0.50f;

    [Tooltip("Time required to pass before entering the fall state. Useful for walking down stairs")]
    public float FallTimeout = 0.15f;

    [Header("Player Grounded")]
    [Tooltip("If the character is grounded or not. Not part of the CharacterController built in grounded check")]
    public bool Grounded = true;

    [Tooltip("Useful for rough ground")]
    public float GroundedOffset = -0.14f;

    [Tooltip("The radius of the grounded check. Should match the radius of the CharacterController")]
    public float GroundedRadius = 0.28f;

    [Tooltip("What layers the character uses as ground")]
    public LayerMask GroundLayers;



    // player
    private float _animationBlend;
    private float _targetRotation = 0.0f;
    private float _rotationVelocity;
    private float _verticalVelocity;
    private float _terminalVelocity = 53.0f;

    // timeout deltatime
    private float _jumpTimeoutDelta;
    private float _fallTimeoutDelta;

    // animation IDs
    private int _animIDSpeed;
    private int _animIDGrounded;
    private int _animIDJump;
    private int _animIDFreeFall;
    private int _animIDMotionSpeed;

    private PlayerInput _playerInput;
    private Animator _animator;
    private CharacterController _controller;
    private PlayerCharacterInput _input;
    private GameObject _mainCamera;

    private const float _threshold = 0.01f;

    private bool _hasAnimator;

    //MoveData for client simulation
    private MoveData _clientMoveData;

    //MoveData for replication
    public struct MoveData: IReplicateData
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

        _controller.enabled = (base.IsServer || base.IsOwner);

        if (base.IsOwner)
        {
            _mainCamera = GameObject.FindGameObjectWithTag("MainCamera");
            _input = GetComponent<PlayerCharacterInput>();            
        }
    }

    public override void OnStartNetwork()
    {
        base.OnStartNetwork();

        _hasAnimator = TryGetComponent(out _animator);

        AssignAnimationIDs();

        // reset our timeouts on start
        _fallTimeoutDelta = FallTimeout;
        _jumpTimeoutDelta = JumpTimeout;
    }

    private void TimeManager_OnTick()
    {
        if (base.IsOwner)
        {
            Reconciliation(default, false);
            CheckInput(out MoveData md);
            Move(md, false);
        }
        if (base.IsServer)
        {
            Move(default, true);
            ReconcileData rd = new ReconcileData(transform.position, transform.rotation, _verticalVelocity, _fallTimeoutDelta, _jumpTimeoutDelta, Grounded);
            Reconciliation(rd, true);
        }
    }

    private void TimeManager_OnUpdate()
    {
        if (base.IsOwner)
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
        _fallTimeoutDelta = rd.FallTimeout;
        _jumpTimeoutDelta = rd.JumpTimeout;
        Grounded = rd.Grounded;
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
        _animIDGrounded = Animator.StringToHash("Grounded");
        _animIDJump = Animator.StringToHash("Jump");
        _animIDFreeFall = Animator.StringToHash("FreeFall");
        _animIDMotionSpeed = Animator.StringToHash("MotionSpeed");
    }

    private void GroundedCheck()
    {
        // set sphere position, with offset
        Vector3 spherePosition = new Vector3(transform.position.x, transform.position.y - GroundedOffset,
            transform.position.z);
        Grounded = Physics.CheckSphere(spherePosition, GroundedRadius, GroundLayers,
            QueryTriggerInteraction.Ignore);

        // update animator if using character
        if (_hasAnimator)
        {
            _animator.SetBool(_animIDGrounded, Grounded);
        }
    }

    private void MoveWithData(MoveData md, float delta)
    {
        // set target speed based on move speed, sprint speed and if sprint is pressed
        float targetSpeed = md.Sprint ? SprintSpeed : MoveSpeed;

        // a simplistic acceleration and deceleration designed to be easy to remove, replace, or iterate upon

        // note: Vector2's == operator uses approximation so is not floating point error prone, and is cheaper than magnitude
        // if there is no input, set the target speed to 0
        if (md.Move == Vector2.zero) targetSpeed = 0.0f;

        _animationBlend = Mathf.Lerp(_animationBlend, targetSpeed, delta * SpeedChangeRate);
        if (_animationBlend < 0.01f) _animationBlend = 0f;

        // normalise input direction
        Vector3 inputDirection = new Vector3(md.Move.x, 0.0f, md.Move.y).normalized;

        // note: Vector2's != operator uses approximation so is not floating point error prone, and is cheaper than magnitude
        // if there is a move input rotate player when the player is moving
        if (md.Move != Vector2.zero)
        {
            _targetRotation = Mathf.Atan2(inputDirection.x, inputDirection.z) * Mathf.Rad2Deg + md.CameraEulerY;

            // rotate to face input direction relative to camera position
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(0.0f, _targetRotation, 0.0f), RotationSmoothTime * delta);
        }

        Vector3 targetDirection = Quaternion.Euler(0.0f, _targetRotation, 0.0f) * Vector3.forward;

        // move the player
        _controller.Move(targetDirection.normalized * (targetSpeed * delta) +
                         new Vector3(0.0f, _verticalVelocity, 0.0f) * delta);

        // update animator if using character
        if (_hasAnimator)
        {
            _animator.SetFloat(_animIDSpeed, _animationBlend);
            _animator.SetFloat(_animIDMotionSpeed, 1f);
        }
    }

    private void JumpAndGravity(MoveData md, float delta)
    {
        if (Grounded)
        {
            // reset the fall timeout timer
            _fallTimeoutDelta = FallTimeout;

            // update animator if using character
            if (_hasAnimator)
            {
                _animator.SetBool(_animIDJump, false);
                _animator.SetBool(_animIDFreeFall, false);
            }

            // stop our velocity dropping infinitely when grounded
            if (_verticalVelocity < 0.0f)
            {
                _verticalVelocity = -2f;
            }

            // Jump
            if (md.Jump && _jumpTimeoutDelta <= 0.0f)
            {
                // the square root of H * -2 * G = how much velocity needed to reach desired height
                _verticalVelocity = Mathf.Sqrt(JumpHeight * -2f * Gravity);

                // update animator if using character
                if (_hasAnimator)
                {
                    _animator.SetBool(_animIDJump, true);
                }
            }

            // jump timeout
            if (_jumpTimeoutDelta >= 0.0f)
            {
                _jumpTimeoutDelta -= delta;
            }
        }
        else
        {
            // reset the jump timeout timer
            _jumpTimeoutDelta = JumpTimeout;

            // fall timeout
            if (_fallTimeoutDelta >= 0.0f)
            {
                _fallTimeoutDelta -= delta;
            }
            else
            {
                // update animator if using character
                if (_hasAnimator)
                {
                    _animator.SetBool(_animIDFreeFall, true);
                }
            }
        }

        // apply gravity over time if under terminal (multiply by delta time twice to linearly speed up over time)
        if (_verticalVelocity < _terminalVelocity)
        {
            _verticalVelocity += Gravity * delta;
        }
    }

    private void OnDrawGizmosSelected()
    {
        Color transparentGreen = new Color(0.0f, 1.0f, 0.0f, 0.35f);
        Color transparentRed = new Color(1.0f, 0.0f, 0.0f, 0.35f);

        if (Grounded) Gizmos.color = transparentGreen;
        else Gizmos.color = transparentRed;

        // when selected, draw a gizmo in the position of, and matching radius of, the grounded collider
        Gizmos.DrawSphere(
            new Vector3(transform.position.x, transform.position.y - GroundedOffset, transform.position.z),
            GroundedRadius);
    }

    private void OnFootstep(AnimationEvent animationEvent)
    {
        if (!base.IsOwner) return;

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
        if (!base.IsOwner) return;

        if (animationEvent.animatorClipInfo.weight > 0.5f)
        {
            AudioSource.PlayClipAtPoint(LandingAudioClip, transform.TransformPoint(_controller.center), FootstepAudioVolume);
        }
    }
}