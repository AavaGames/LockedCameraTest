using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Skills
{
    [CreateAssetMenu(fileName = "Cardium", menuName = "AttackSystem/SkillLibrary")]
    public class SkillLibrary : ScriptableObject
    {
        public List<AttackClass> skills;
        public bool includeTestingSkills;
    }
}
