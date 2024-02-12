using Assets.App.Scripts.Characters;
using FishNet.Object;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Characters
{
    public class Character : NetworkBehaviour
    {
        public PlayerInputController Input { get; private set; }
        public CharacterCamera Camera { get; private set; }
        public CharacterMovement Movement { get; private set; }
        public CharacterSkills Skills { get; private set; }

        public CharacterHealth Health { get; private set; }


        private void Awake()
        {
            Cursor.lockState = CursorLockMode.Locked;

            Input = GetComponent<PlayerInputController>();
            Camera = GetComponent<CharacterCamera>();
            Movement = GetComponent<CharacterMovement>();
            Skills = GetComponent<CharacterSkills>();
            Health = GetComponent<CharacterHealth>();
        }

        private void Update()
        {
            if (IsOwner)
            {
                if (Input.Actions["Pause"].WasPressedThisFrame())
                {
                    Cursor.lockState = CursorLockMode.None;
                }
                else if (UnityEngine.Input.GetMouseButtonDown(1))
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

