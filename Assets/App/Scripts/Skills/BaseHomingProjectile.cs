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
        public float ProjectileSpeed = 5;
        public float RotateSpeed = 2;
        public Rigidbody ProjectileRB;
        private Vector3 _heading;

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
            ProjectileRB.velocity = transform.forward * ProjectileSpeed;

            //rotation, probably needs to include global rotation speed value

            // By default be shot forward
            Vector3 target = transform.position + Character.transform.forward;
            if (Character.Camera.Targeting)
                target = Character.Camera.CurrentTarget.transform.position;

            _heading = target - transform.position;

            var rotating = Quaternion.LookRotation(_heading);
            ProjectileRB.MoveRotation(Quaternion.RotateTowards(transform.rotation, rotating, RotateSpeed * Time.deltaTime));
        }
    }
}
