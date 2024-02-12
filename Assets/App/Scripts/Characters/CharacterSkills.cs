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

        private bool _canUseSkill = true;

        [Required]
        public SkillLibrary SkillLibrary;

        public enum SkillDirection { North, East, South, West }

        private class SkillContainer
        {
            public Skill Skill;
            public TextMeshProUGUI TextMesh;
            public bool Queued;
        }

        private Dictionary<SkillDirection, SkillContainer> _skills = new Dictionary<SkillDirection, SkillContainer>();

        [Required]
        [Foldout("Dependencies")]
        public TextMeshProUGUI SkillNorthText;
        [Required]
        [Foldout("Dependencies")]
        public TextMeshProUGUI SkillEastText;
        [Required]
        [Foldout("Dependencies")]
        public TextMeshProUGUI SkillSouthText;
        [Required]
        [Foldout("Dependencies")]
        public TextMeshProUGUI SkillWestText;

        void Awake()
        {
            InstanceFinder.TimeManager.OnUpdate += TimeManager_OnUpdate;
            InstanceFinder.TimeManager.OnTick += TimeManager_OnTick;

            _character = GetComponent<Character>();
            _input = GetComponent<PlayerInputController>();
            _networkAnimator = GetComponent<NetworkAnimator>();

            foreach (SkillDirection direction in Enum.GetValues(typeof(SkillDirection)))
            {
                _skills.Add(direction, new SkillContainer());
            }

            _skills[SkillDirection.North].TextMesh = SkillNorthText;
            _skills[SkillDirection.East].TextMesh = SkillEastText;
            _skills[SkillDirection.South].TextMesh = SkillSouthText;
            _skills[SkillDirection.West].TextMesh = SkillWestText;

            UpdateSkill(_skills[SkillDirection.North], 1);
            UpdateSkill(_skills[SkillDirection.East], 0);
            UpdateSkill(_skills[SkillDirection.South], 2);
            UpdateSkill(_skills[SkillDirection.West], 3);
        }

        private void UpdateSkill(SkillContainer skillContainer, int skillIndex)
        {
            skillContainer.Skill = SkillLibrary.Skills[skillIndex];
            skillContainer.TextMesh.text = skillContainer.Skill.Name;
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

            if (_input.Actions["SkillNorth"].WasPressedThisFrame())
                _skills[SkillDirection.North].Queued = true;
            if (_input.Actions["SkillEast"].WasPressedThisFrame())
                _skills[SkillDirection.East].Queued = true;
            if (_input.Actions["SkillSouth"].WasPressedThisFrame())
                _skills[SkillDirection.South].Queued = true;
            if (_input.Actions["SkillWest"].WasPressedThisFrame())
                _skills[SkillDirection.West].Queued = true;
        }

        private void TimeManager_OnTick()
        {
            foreach (SkillDirection direction in Enum.GetValues(typeof(SkillDirection)))
            {
                SkillContainer currentSkill = _skills[direction];
                if (currentSkill.Queued)
                {
                    // Client Attacks
                    ExecuteAttack(currentSkill.Skill);
                    // Update server with animation + movement
                    CmdExecuteAttack(currentSkill.Skill);

                    currentSkill.Queued = false;
                }
            }
        }

        [Client]
        public void ExecuteAttack(Skill skill)
        {
            if (_canUseSkill)
            {
                if (!_character.Movement.Grounded && !skill.CanUseInAir)
                    return;

                Debug.Log("Attack Executed");

                _canUseSkill = false;

                // Face target
                if (_character.Camera.Targeting && _character.Camera.CurrentTarget != null)
                {
                    Vector3 dir = transform.position - _character.Camera.CurrentTarget.transform.position;
                    dir = dir.normalized;
                    float rotation = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
                    transform.rotation = Quaternion.Euler(0, rotation - 180, 0);
                }

                // Crossfading causes non-owner Characters to get stuck on non-host clients
                //_networkAnimator.CrossFade(attack.attackAnimation, 0.25f, 0);

                _networkAnimator.Play(skill.AnimationName);

                _character.Movement.Deactivate();
                _character.Movement.ResetVerticalVelocity();
            }
        }

        [ServerRpc]
        private void CmdExecuteAttack(Skill attack)
        {
            // Skip if client host
            if (!IsOwner)
            {
                Debug.Log("SERVER: " + gameObject.name + " is executing attack");

                if (!_canUseSkill)
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
                skillObj.Character = _character;
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
            _character.Movement.Activate();
            _canUseSkill = true;
        }
    }
}