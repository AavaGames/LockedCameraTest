using FishNet.Object;
using System.Collections;
using UnityEngine;
using Assets.App.Scripts.Characters;

namespace Assets.App.Scripts.Skills
{
    public class SkillObject : NetworkBehaviour
    {
        public Character character;

        protected NetworkObject nob;

        protected void Awake()
        {
            nob = GetComponent<NetworkObject>();
        }
    }
}