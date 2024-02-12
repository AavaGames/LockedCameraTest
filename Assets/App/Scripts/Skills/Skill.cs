using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Skills
{
    [CreateAssetMenu(fileName = "Skill", menuName = "Skill System/Skill", order = 1)]
    public class Skill : ScriptableObject
    {
        // How will this be language localized?

        public int ID = -1;
        new public string Name;
        [Tooltip("The text description of the move.")]
        public string Description;

        [Space(10)]
        [Tooltip("The mana cost to cast")]
        public int Cost = 1;
        [Tooltip("The amount of times the skill can be used. (-1 is infinite)")]
        public int Uses = -1;

        public enum SkillType { None, Offensive, Defensive, Erase, Status, Special, Environment }

        public enum SkillSchool { None, Nature, Tech, Mind, Body, Spirit }
        [Space(10)]
        public SkillType Type = SkillType.None;
        public SkillSchool School = SkillSchool.None;

        [Space(10)]
        public string AnimationName;

        [Space(10)]
        public bool CanUseInAir = false;
        public bool IsMelee = false; // change into enum?


        [Header("Ranged")]
        public float HomingAccuracy = 1.0f;
        public float MaxRange = 0.0f;

        [Header("Melee")]
        public bool IsComboAttack = false;
        public Skill ComboInto;
        public float MeleeDashRange = 0.0f; // example variables

        // Create multiple sub classes for the different skill types
        // Attack variables are not the same as status / special / environmental
        // Some status are projectiles, some are global
        // Some special are buffs, some are "attacks"
    }
}