using FishNet.Object;
using NaughtyAttributes;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Assets.App.Scripts.Character
{
    [DisallowMultipleComponent]
    [RequireComponent(typeof(PlayerInput))]
    public class PlayerInputController : NetworkBehaviour
    {
        public PlayerInput input { get; private set; }
        
        public InputActionAsset actions { get { return input.actions; } }

        public Vector2 move { get; private set; }
        public Vector2 look { get; private set; }

        public bool IsCurrentDeviceMouse
        {
            get
            {
                if (input == null) return false;
                return input.currentControlScheme == "Keyboard Mouse";
            }
        }


        private void Awake()
        {
            input = GetComponent<PlayerInput>();
            input.enabled = false;
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            if (IsOwner)
            {
                input.enabled = true;

#if DEVELOPMENT_BUILD || UNITY_EDITOR
                input.actions.FindActionMap("Dev").Enable();
#endif
            }
        }

        public void ActivateInput()
        {
            input.ActivateInput();
        }

        public void DeactivateInput()
        {
            input.DeactivateInput();
        }

        public InputAction GetAction(string actionName)
        {
            return input.actions[actionName];
        }


        #region Inputs

        public void OnMove(InputValue inputValue)
        {
            move = inputValue.Get<Vector2>();
        }

        public void OnLook(InputValue inputValue)
        {
            look = inputValue.Get<Vector2>();
        }


        // Examples
        public bool MovementAbilityPressed()
        {
            return input.actions["MovementAbility"].WasPerformedThisFrame();
        }

        #endregion

        public virtual bool IsMoving()
        {
            bool hasHorizontalInput = !Mathf.Approximately(move.x, 0f);
            bool hasVerticalInput = !Mathf.Approximately(move.y, 0f);
            return hasHorizontalInput || hasVerticalInput;
        }

        public bool MouseToWorldHitPoint(out RaycastHit hit, float maxCheckDistance = Mathf.Infinity)
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            return Physics.Raycast(ray, out hit, maxCheckDistance);
        }

    }
}
