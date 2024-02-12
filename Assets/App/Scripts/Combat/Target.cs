using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Combat
{
    public class Target : MonoBehaviour
    {
        public TargetManager TargetManager;
        [Tooltip("Team target is on (-1 = no team)")]
        public int Team = -1;
        public bool HasNewTargets = true;

        private void Start()
        {
            TargetManager = FindObjectOfType<TargetManager>();
            TargetManager.AddTarget(this);
        }

        private void OnDestroy()
        {
            TargetManager.RemoveTarget(this);
        }

        public List<Target> GetTargets(bool getTeammates)
        {
            return TargetManager.GetTargets(this, getTeammates);
        }
    }
}