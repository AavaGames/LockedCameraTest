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
using UnityEngine.TextCore.Text;

namespace Assets.App.Script.Character
{
    public class CharacterSkills : NetworkBehaviour
    {
        private Character _character;
        private NetworkAnimator _networkAnimator;
        private PlayerInputController _input;

        private bool canAttack = true;

        [Required]
        public SkillLibrary skillLibrary;

        public enum SkillDirection { North, East, South, West }

        private class Skill
        {
            public AttackClass skill;
            public TextMeshProUGUI textMesh;
            public bool queued;
        }

        private Dictionary<SkillDirection, Skill> skills = new Dictionary<SkillDirection, Skill>();

        [Foldout("Dependency")]
        public TextMeshProUGUI skillNorthText;
        [Foldout("Dependency")]
        public TextMeshProUGUI skillEastText;
        [Foldout("Dependency")]
        public TextMeshProUGUI skillSouthText;
        [Foldout("Dependency")]
        public TextMeshProUGUI skillWestText;

        void Awake()
        {
            InstanceFinder.TimeManager.OnUpdate += TimeManager_OnUpdate;
            InstanceFinder.TimeManager.OnTick += TimeManager_OnTick;

            _character = GetComponent<Character>();
            _input = GetComponent<PlayerInputController>();
            _networkAnimator = GetComponent<NetworkAnimator>();

            foreach (SkillDirection direction in Enum.GetValues(typeof(SkillDirection)))
            {
                skills.Add(direction, new Skill());
            }

            skills[SkillDirection.North].textMesh = skillNorthText;
            skills[SkillDirection.East].textMesh = skillEastText;
            skills[SkillDirection.South].textMesh = skillSouthText;
            skills[SkillDirection.West].textMesh = skillWestText;

            UpdateSkill(skills[SkillDirection.North], 1);
            UpdateSkill(skills[SkillDirection.East], 2);
            UpdateSkill(skills[SkillDirection.South], 3);
            UpdateSkill(skills[SkillDirection.West], 4);
        }

        private void UpdateSkill(Skill skill, int skillIndex)
        {
            skill.skill = skillLibrary.skills[skillIndex];
            skill.textMesh.text = skill.skill.attackName;
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            if (IsOwner)
            {
                
            }
        }

        public override void OnStopClient()
        {
            base.OnStopClient();

            if (IsOwner)
            {
                
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

            if (_input.actions["SkillNorth"].WasPressedThisFrame())
                skills[SkillDirection.North].queued = true;
            if (_input.actions["SkillEast"].WasPressedThisFrame())
                skills[SkillDirection.East].queued = true;
            if (_input.actions["SkillSouth"].WasPressedThisFrame())
                skills[SkillDirection.South].queued = true;
            if (_input.actions["SkillWest"].WasPressedThisFrame())
                skills[SkillDirection.West].queued = true;
        }

        private void TimeManager_OnTick()
        {
            foreach (SkillDirection direction in Enum.GetValues(typeof(SkillDirection)))
            {
                Skill currentSkill = skills[direction];
                if (currentSkill.queued)
                {
                    // Client Attacks
                    ExecuteAttack(currentSkill.skill);
                    // Update server with animation + movement
                    CmdExecuteAttack(currentSkill.skill);

                    currentSkill.queued = false;
                }
            }
        }

        [Client]
        public void ExecuteAttack(AttackClass attack)
        {
            if (canAttack)
            {
                Debug.Log("Attack Executed");

                canAttack = false;

                // Face target
                if (_character.camera.Targeting && _character.camera.CurrentTarget != null)
                {
                    Vector3 dir = transform.position - _character.camera.CurrentTarget.transform.position;
                    dir = dir.normalized;
                    float rotation = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
                    transform.rotation = Quaternion.Euler(0, rotation - 180, 0);
                }

                // Crossfading causes non-owner Characters to get stuck on non-host clients
                //_networkAnimator.CrossFade(attack.attackAnimation, 0.25f, 0);

                _networkAnimator.Play(attack.attackAnimation);

                _character.movement.Deactivate();
            }
        }

        [ServerRpc]
        private void CmdExecuteAttack(AttackClass attack)
        {
            // Skip if client host
            if (!IsOwner)
            {
                Debug.Log("SERVER: " + gameObject.name + " is executing attack");

                if (!canAttack)
                {
                    Debug.LogWarning("SERVER ERROR: Player Is not allowed to attack");
                    // Kick player out of animation
                }

                ExecuteAttack(attack);
            }
        }

        // TODO change name to SpawnSkillObject_

        // animation event object spawn
        public void SpawnObjectLocal(GameObject spawnedObj)
        {
            if (IsServer)
            {
                GameObject currentObj = Instantiate(spawnedObj, transform, false);

                // TODO change to SkillObject class that is held by all of them
                var obj = currentObj.GetComponent<BaseHomingProjectile>();
                if (obj != null)
                {
                    obj.character = _character;
                }

                Spawn(currentObj, LocalConnection);
                // NOTE not totally sure if this is giving ownership to the caller or to every client
            }
        }

        public void SpawnObjectGlobal(GameObject spawnedObj)
        {
            if (IsServer)
            {
                GameObject currentObj = Instantiate(spawnedObj, transform, false);

                var obj = currentObj.GetComponent<BaseHomingProjectile>();
                if (obj != null)
                {
                    obj.character = _character;
                }

                currentObj.transform.parent = null;
                Spawn(currentObj, LocalConnection);
            }
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