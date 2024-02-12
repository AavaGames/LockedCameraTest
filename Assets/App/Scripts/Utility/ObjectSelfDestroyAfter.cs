using FishNet.Object;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Scripts.Utility
{
    public class ObjectSelfDestroyAfter : NetworkBehaviour
    {
        public float DestroyAfter = 5;

        public override void OnStartClient()
        {
            base.OnStartClient();

            if (IsServer)
            {
                StartCoroutine(DespawnAfter());
            }
        }

        IEnumerator DespawnAfter()
        {
            yield return new WaitForSeconds(DestroyAfter);
            Despawn();
        }
    }
}
