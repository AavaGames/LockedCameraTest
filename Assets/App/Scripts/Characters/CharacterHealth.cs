using FishNet.Object;
using System.Collections;
using UnityEngine;

namespace Assets.App.Scripts.Characters
{
    public class CharacterHealth : NetworkBehaviour
    {
        public int Health { get; private set; }
        private int _maxHealth = 20;
        public int MaxHealth => MaxHealth;
        
    }
}