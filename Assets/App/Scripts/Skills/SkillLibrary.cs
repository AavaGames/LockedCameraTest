using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Skills
{
    [CreateAssetMenu(fileName = "SkillLibrary", menuName = "Skill System/Skill Library")]
    public class SkillLibrary : ScriptableObject
    {
        public List<Skill> skills;
        public bool includeTestingSkills;
    }
}
