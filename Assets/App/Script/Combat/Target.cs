using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Script.Combat
{
    public class Target : MonoBehaviour
    {
        public TargetManager targetManager;
        [Tooltip("Team target is on (-1 = no team)")]
        public int team = -1;
        public bool hasNewTargets = true;

        private void Start()
        {
            targetManager = FindObjectOfType<TargetManager>();
            targetManager.AddTarget(this);
        }

        private void OnDestroy()
        {
            targetManager.RemoveTarget(this);
        }

        public List<Target> GetTargets(bool getTeammates)
        {
            return targetManager.GetTargets(this, getTeammates);
        }
    }
}