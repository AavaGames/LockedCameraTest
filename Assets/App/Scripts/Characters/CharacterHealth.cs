using FishNet.Object;
using System.Collections;
using UnityEngine;

namespace Assets.App.Scripts.Characters
{
    public class CharacterHealth : NetworkBehaviour
    {
        public int health { get; private set; }
        private int maxHealth = 20;
        public int MaxHealth => MaxHealth;
        
    }
}