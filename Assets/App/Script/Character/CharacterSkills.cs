using Assets.App.Scripts.Character;
using FishNet;
using FishNet.Component.Animating;
using FishNet.Object;
using NaughtyAttributes;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Assets.App.Script.Character
{
    public class CharacterSkills : NetworkBehaviour
    {
        private Character _character;
        private Animator _animator;
        private NetworkAnimator _networkAnimator;
        private PlayerInputController _input;

        private bool canAttack = true;

        [Required]
        public SkillLibrary skillLibrary;

        private AttackClass skillNorth;

        [Foldout("Dependency")]
        public TextMeshProUGUI skillNorthText;

        private Action<InputAction.CallbackContext> attackAction;

        void Awake()
        {
            InstanceFinder.TimeManager.OnUpdate += TimeManager_OnUpdate;
            InstanceFinder.TimeManager.OnTick += TimeManager_OnTick;

            _character = GetComponent<Character>();
            _animator = GetComponent<Animator>();
            _input = GetComponent<PlayerInputController>();
            _networkAnimator = GetComponent<NetworkAnimator>();

            NextSkill();
        }

        private void NextSkill()
        {
            skillNorth = skillLibrary.skills[1];
            skillNorthText.text = skillNorth.attackName;
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            if (IsOwner)
            {
                attackAction = ctx => ExecuteAttack();
                _input.actions["SkillNorth"].performed += attackAction;
            }
        }

        public override void OnStopClient()
        {
            base.OnStopClient();

            if (IsOwner)
            {
                _input.actions["SkillNorth"].performed -= attackAction;
            }
        }

        private void OnDestroy()
        {
            if (InstanceFinder.TimeManager != null)
            {
                InstanceFinder.TimeManager.OnUpdate -= TimeManager_OnUpdate;
                InstanceFinder.TimeManager.OnTick -= TimeManager_OnTick;
            }
        }

        private void TimeManager_OnUpdate()
        {
            // input queue
        }

        private void TimeManager_OnTick()
        {
            // execute
        }

        [Client]
        public void ExecuteAttack()
        {
            if (canAttack)
            {
                canAttack = false;

                Debug.Log("Executing attack local");

                // Face target
                if (_character.camera.Targeting && _character.camera.CurrentTarget != null)
                {
                    Vector3 dir = transform.position - _character.camera.CurrentTarget.transform.position;
                    dir = dir.normalized;
                    float rotation = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
                    transform.rotation = Quaternion.Euler(0, rotation - 180, 0);
                }

                // playing the animation
                AttackClass attack = skillNorth;

                _networkAnimator.CrossFade(attack.attackAnimation, 0.1f, 0);

                _character.movement.Deactivate();

                // Update server with animation + movement
                RPCExecuteAttack(attack);
            }
        }

        [ServerRpc]
        public void RPCExecuteAttack(AttackClass attack)
        {
            Debug.Log(gameObject.name + " is executing attack");
            
            // playing the animation

            // on non-host client, other players get stuck on this animation as if it was paused
            _networkAnimator.CrossFade(attack.attackAnimation, 0.1f, 0); 

            // 1. SEE IF THIS IS CALLED MULTIPLE TIME
            // 2. LOOK INTO ANIMATION BEHAVIORS FOR ONSTATEENTERED

            _character.movement.Deactivate();
        }

        // animation event object spawn
        [ServerRpc]
        public void SpawnObjectLocal(GameObject spawnedObj)
        {

            GameObject currentObj = Instantiate(spawnedObj, transform, false);
            Spawn(currentObj, LocalConnection);
            // NOTE not totally sure if this is giving ownership to the caller or to every client
        }

        [ServerRpc]
        public void SpawnObjectGlobal(GameObject spawnedObj)
        {

            GameObject currentObj = Instantiate(spawnedObj, transform, false);
            currentObj.transform.parent = null;
            Spawn(currentObj, LocalConnection);
        }

        public void UpdateAttack()
        {

        }

        // releases the character so they are allowed to attack again
        public void AnimationEnd()
        {
            _character.movement.Activate();
            canAttack = true;
        }
    }
}