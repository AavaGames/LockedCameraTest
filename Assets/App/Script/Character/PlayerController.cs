using FishNet.Object;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.App.Script.Character
{
    public class PlayerController : NetworkBehaviour
    {
        private PlayerCameraController _playerCameraController;
        // motor

        public override void OnStartClient()
        {
            base.OnStartClient();
        }

        public override void OnStartNetwork()
        {
            base.OnStartNetwork();

            gameObject.name = "Player (" + ObjectId.ToString() + ")";
        }
    }
}

