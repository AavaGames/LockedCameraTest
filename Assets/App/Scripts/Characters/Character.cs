using Assets.App.Scripts.Characters;
using FishNet.Object;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Characters
{
    public class Character : NetworkBehaviour
    {
        public PlayerInputController input { get; private set; }
        new public CharacterCamera camera { get; private set; }
        public CharacterMovement movement { get; private set; }
        public CharacterSkills skills { get; private set; }

        public CharacterHealth health { get; private set; }


        private void Awake()
        {
            Cursor.lockState = CursorLockMode.Locked;

            input = GetComponent<PlayerInputController>();
            camera = GetComponent<CharacterCamera>();
            movement = GetComponent<CharacterMovement>();
            skills = GetComponent<CharacterSkills>();
            health = GetComponent<CharacterHealth>();
        }

        private void Update()
        {
            if (IsOwner)
            {
                if (input.actions["Pause"].WasPressedThisFrame())
                {
                    Cursor.lockState = CursorLockMode.None;
                }
                else if (Input.GetMouseButtonDown(1))
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

