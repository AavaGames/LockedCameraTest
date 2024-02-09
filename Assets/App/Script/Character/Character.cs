using Assets.App.Scripts.Character;
using FishNet.Object;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Script.Character
{
    public class Character : NetworkBehaviour
    {
        private PlayerInputController _input;
        private CharacterCamera _playerCameraController;
        // motor

        private void Awake()
        {
            Cursor.lockState = CursorLockMode.Locked;

            _input = GetComponent<PlayerInputController>();
        }

        private void Update()
        {
            if (IsOwner)
            {
                if (_input.actions["Pause"].WasPressedThisFrame())
                {
                    Cursor.lockState = CursorLockMode.None;
                }
                else if (Input.GetMouseButtonDown(0))
                {
                    Cursor.lockState = CursorLockMode.Locked;
                }
            }
        }

        public override void OnStartClient()
        {
            base.OnStartClient();
        }

        public override void OnStartNetwork()
        {
            base.OnStartNetwork();

            gameObject.name = "Character (" + ObjectId.ToString() + ")";
        }
    }
}

