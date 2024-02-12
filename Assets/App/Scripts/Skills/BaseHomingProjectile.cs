using FishNet;
using FishNet.Object;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Assets.App.Scripts.Characters;

namespace Assets.App.Scripts.Skills
{
    public class BaseHomingProjectile : SkillObject
    {
        public float projectileSpeed = 5;
        public float rotateSpeed = 2;
        public Rigidbody projectileRB;
        private Vector3 heading;

        private void Awake()
        {
            base.Awake();

            InstanceFinder.TimeManager.OnTick += TimeManager_OnTick;
        }

        private void OnDestroy()
        {
            if (InstanceFinder.TimeManager != null)
            {
                InstanceFinder.TimeManager.OnTick -= TimeManager_OnTick;
            }
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            // save target here
        }

        private void TimeManager_OnTick()
        {
            //speed, probably needs to include global speed value from buffs
            projectileRB.velocity = transform.forward * projectileSpeed;

            //rotation, probably needs to include global rotation speed value

            // By default be shot forward
            Vector3 target = transform.position + character.transform.forward;
            if (character.camera.Targeting)
                target = character.camera.CurrentTarget.transform.position;

            heading = target - transform.position;

            var rotating = Quaternion.LookRotation(heading);
            projectileRB.MoveRotation(Quaternion.RotateTowards(transform.rotation, rotating, rotateSpeed * Time.deltaTime));
        }
    }
}
