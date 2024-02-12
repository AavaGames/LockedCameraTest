using Assets.App.Scripts.Characters;
using Assets.App.Scripts.Skills;
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

namespace Assets.App.Scripts.Characters
{
    public class CharacterSkills : NetworkBehaviour
    {
        private Character _character;
        private NetworkAnimator _networkAnimator;
        private PlayerInputController _input;

        private bool canUseSkill = true;

        [Required]
        public SkillLibrary skillLibrary;

        public enum SkillDirection { North, East, South, West }

        private class SkillContainer
        {
            public Skill skill;
            public TextMeshProUGUI textMesh;
            public bool queued;
        }

        private Dictionary<SkillDirection, SkillContainer> skills = new Dictionary<SkillDirection, SkillContainer>();

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
                skills.Add(direction, new SkillContainer());
            }

            skills[SkillDirection.North].textMesh = skillNorthText;
            skills[SkillDirection.East].textMesh = skillEastText;
            skills[SkillDirection.South].textMesh = skillSouthText;
            skills[SkillDirection.West].textMesh = skillWestText;

            UpdateSkill(skills[SkillDirection.North], 1);
            UpdateSkill(skills[SkillDirection.East], 0);
            UpdateSkill(skills[SkillDirection.South], 2);
            UpdateSkill(skills[SkillDirection.West], 3);
        }

        private void UpdateSkill(SkillContainer skillContainer, int skillIndex)
        {
            skillContainer.skill = skillLibrary.skills[skillIndex];
            skillContainer.textMesh.text = skillContainer.skill.name;
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
                SkillContainer currentSkill = skills[direction];
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
        public void ExecuteAttack(Skill skill)
        {
            if (canUseSkill)
            {
                if (!_character.movement.grounded && !skill.canUseInAir)
                    return;

                Debug.Log("Attack Executed");

                canUseSkill = false;

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

                _networkAnimator.Play(skill.animationName);

                _character.movement.Deactivate();
                _character.movement.ResetVerticalVelocity();
            }
        }

        [ServerRpc]
        private void CmdExecuteAttack(Skill attack)
        {
            // Skip if client host
            if (!IsOwner)
            {
                Debug.Log("SERVER: " + gameObject.name + " is executing attack");

                if (!canUseSkill)
                {
                    Debug.LogWarning("SERVER ERROR: Player Is not allowed to attack");
                    // Kick player out of animation
                }

                ExecuteAttack(attack);
            }
        }

        public void InitializeSkillObject(SkillObject skillObj)
        {
            if (skillObj != null)
            {
                skillObj.character = _character;
            }
        }

        // animation event object spawn
        public void SpawnSkillObjectLocal(GameObject spawnedObj)
        {
            if (IsServer)
            {
                GameObject currentObj = Instantiate(spawnedObj, transform, false);

                InitializeSkillObject(currentObj.GetComponent<SkillObject>());

                Spawn(currentObj, LocalConnection);
                // NOTE not totally sure if this is giving ownership to the caller or to every client
            }
        }

        public void SpawnSkillObjectGlobal(GameObject spawnedObj)
        {
            if (IsServer)
            {
                GameObject currentObj = Instantiate(spawnedObj, transform, false);

                InitializeSkillObject(currentObj.GetComponent<SkillObject>());

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
            canUseSkill = true;
        }
    }
}