using FishNet.Object;
using System.Collections;
using UnityEngine;
using Assets.App.Scripts.Characters;

namespace Assets.App.Scripts.Skills
{
    public class SkillObject : NetworkBehaviour
    {
        public Character Character;

        protected NetworkObject _nob;

        protected void Awake()
        {
            _nob = GetComponent<NetworkObject>();
        }
    }
}