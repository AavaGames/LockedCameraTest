using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Skills
{
    [CreateAssetMenu(fileName = "Data", menuName = "Skill System/Skill", order = 1)]
    public class Skill : ScriptableObject
    {
        // How will this be language localized?

        public int ID = -1;
        new public string name;
        [Tooltip("The text description of the move.")]
        public string description;
        [Tooltip("The mana cost to cast")]
        public int cost = 1;
        [Tooltip("The amount of times the skill can be used. (-1 is infinite)")]
        public int uses = -1;

        public enum SkillType { None, Offensive, Defensive, Erase, Status, Special, Environment }

        public enum SkillSchool { None, Nature, Tech, Mind, Body, Spirit }
        public SkillType type = SkillType.None;
        public SkillSchool school = SkillSchool.None;

        [Space(10)]
        public string animationName;

        [Space(10)]
        public bool canUseInAir = false;
        public bool isMelee = false; // change into enum?


        [Header("Ranged")]
        public float homingAccuracy = 1.0f;
        public float maxRange = 0.0f;

        [Header("Melee")]
        public bool isComboAttack = false;
        public Skill comboInto;
        public float meleeDashRange = 0.0f; // example variables

        // Create multiple sub classes for the different skill types
        // Attack variables are not the same as status / special / environmental
        // Some status are projectiles, some are global
        // Some special are buffs, some are "attacks"
    }
}