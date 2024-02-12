using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Combat
{
    public class TargetManager : MonoBehaviour
    {
        private List<Target> targets = new List<Target>();
        private int teams = 1;

        // Use this for initialization
        void Start()
        {
            
        }

        // Update is called once per frame
        void Update()
        {
            
        }

        /// <summary>
        /// Called by targets added after scene creation
        /// </summary>
        public void AddTarget(Target target)
        {
            AddTargetToList(target);
        }

        public void RemoveTarget(Target target)
        {
            targets.Remove(target);

            foreach (Target t in targets)
            {
                t.hasNewTargets = true;
            }
        }

        private void AddTargetToList(Target target)
        {
            targets.Add(target);
            target.team = teams;
            teams++;

            foreach (Target t in targets)
            {
                t.hasNewTargets = true;
            }
        }

        private void FindAllTargetsInScene()
        {
            targets.Clear();
            foreach (var target in FindObjectsOfType<Target>())
            {
                AddTargetToList(target);
            }
        }

        /// <summary>
        /// Returns all valid targets, ignores self
        /// </summary>
        /// <param name="getTeammates">Whether to add teammates into valid target list</param>
        public List<Target> GetTargets(Target caller, bool getTeammates)
        {
            List<Target> validTargets = new List<Target>();
            for (int i = 0; i < targets.Count; i++)
            {
                var target = targets[i];
                if (target == caller)
                    continue;

                if (getTeammates)
                    validTargets.Add(target);
                else if (target.team < 0)
                    validTargets.Add(target);
                else if (target.team != caller.team)
                    validTargets.Add(target);
            }
            return validTargets;
        }

    }
}