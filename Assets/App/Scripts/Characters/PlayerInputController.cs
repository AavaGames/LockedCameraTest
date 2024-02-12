using FishNet.Object;
using NaughtyAttributes;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Assets.App.Scripts.Characters
{
    [DisallowMultipleComponent]
    [RequireComponent(typeof(PlayerInput))]
    public class PlayerInputController : NetworkBehaviour
    {
        public PlayerInput Input { get; private set; }
        
        public InputActionAsset Actions { get { return Input.actions; } }

        public Vector2 Move { get; private set; }
        public Vector2 Look { get; private set; }

        public bool IsCurrentDeviceMouse
        {
            get
            {
                if (Input == null) return false;
                return Input.currentControlScheme == "Keyboard Mouse";
            }
        }

        private void Awake()
        {
            Input = GetComponent<PlayerInput>();
            Input.enabled = false;
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            if (IsOwner)
            {
                Input.enabled = true;

#if DEVELOPMENT_BUILD || UNITY_EDITOR
                Input.actions.FindActionMap("Dev").Enable();
#endif
            }
        }

        public void ActivateInput()
        {
            Input.ActivateInput();
        }

        public void DeactivateInput()
        {
            Input.DeactivateInput();
        }

        public InputAction GetAction(string actionName)
        {
            return Input.actions[actionName];
        }


        #region Inputs

        public void OnMove(InputValue inputValue)
        {
            Move = inputValue.Get<Vector2>();
        }

        public void OnLook(InputValue inputValue)
        {
            Look = inputValue.Get<Vector2>();
        }


        // Examples
        public bool MovementAbilityPressed()
        {
            return Input.actions["MovementAbility"].WasPerformedThisFrame();
        }

        #endregion

        public virtual bool IsMoving()
        {
            bool hasHorizontalInput = !Mathf.Approximately(Move.x, 0f);
            bool hasVerticalInput = !Mathf.Approximately(Move.y, 0f);
            return hasHorizontalInput || hasVerticalInput;
        }

        public bool MouseToWorldHitPoint(out RaycastHit hit, float maxCheckDistance = Mathf.Infinity)
        {
            Ray ray = Camera.main.ScreenPointToRay(UnityEngine.Input.mousePosition);
            return Physics.Raycast(ray, out hit, maxCheckDistance);
        }

    }
}
