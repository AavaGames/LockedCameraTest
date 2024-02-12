using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Combat
{
    public class TargetManager : MonoBehaviour
    {
        private List<Target> _targets = new List<Target>();
        private int _teams = 1;

        /// <summary>
        /// Called by targets added after scene creation
        /// </summary>
        public void AddTarget(Target target)
        {
            AddTargetToList(target);
        }

        public void RemoveTarget(Target target)
        {
            _targets.Remove(target);

            foreach (Target t in _targets)
            {
                t.HasNewTargets = true;
            }
        }

        private void AddTargetToList(Target target)
        {
            _targets.Add(target);
            target.Team = _teams;
            _teams++;

            foreach (Target t in _targets)
            {
                t.HasNewTargets = true;
            }
        }

        private void FindAllTargetsInScene()
        {
            _targets.Clear();
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
            for (int i = 0; i < _targets.Count; i++)
            {
                var target = _targets[i];
                if (target == caller)
                    continue;

                if (getTeammates)
                    validTargets.Add(target);
                else if (target.Team < 0)
                    validTargets.Add(target);
                else if (target.Team != caller.Team)
                    validTargets.Add(target);
            }
            return validTargets;
        }

    }
}