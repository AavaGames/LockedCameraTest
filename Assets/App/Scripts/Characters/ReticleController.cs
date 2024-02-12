using FishNet;
using FishNet.Object;
using NaughtyAttributes;
using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;

namespace Assets.App.Scripts.Characters
{
    public class ReticleController : NetworkBehaviour
    {
        private CharacterCamera _playerCameraController;

        [Foldout("Dependencies")]
        public Canvas playerCanvas;
        [Foldout("Dependencies")]
        public Image reticle;
        [Foldout("Dependencies")]
        public TextMeshProUGUI distanceText;

        public float closeRange = 5;
        public float midRange = 10;

        // Use this for initialization
        void Awake()
        {
            InstanceFinder.TimeManager.OnLateUpdate += TimeManager_OnLateUpdate;

            _playerCameraController = GetComponent<CharacterCamera>();

            playerCanvas.enabled = false;
            reticle.enabled = false;
            distanceText.enabled = false;
        }

        private void OnDestroy()
        {
            if (InstanceFinder.TimeManager != null)
            {
                InstanceFinder.TimeManager.OnLateUpdate -= TimeManager_OnLateUpdate;
            }
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            if (IsOwner)
            {
                playerCanvas.enabled = true;
            }
        }

        // Update is called once per frame
        private void TimeManager_OnLateUpdate()
        {
            if (_playerCameraController.Targeting)
            {
                UpdateReticle();
                UpdateDistanceText();
            }
        }

        public void Show(bool showDistance = true)
        {
            reticle.enabled = true;
            distanceText.enabled = showDistance;
        }

        public void Hide()
        {
            reticle.enabled = false;
            distanceText.enabled = false;
        }

        private void UpdateReticle()
        {
            Vector3 screenPosition = Camera.main.WorldToScreenPoint(_playerCameraController.CurrentTarget.transform.position);
            
            // Can switch images because its off the screen to point in direction of target
            screenPosition.x = Mathf.Clamp(screenPosition.x, 0, Screen.width);
            screenPosition.y = Mathf.Clamp(screenPosition.y, 0, Screen.height);
            reticle.rectTransform.position = screenPosition;

            if (_playerCameraController.TargetDistance <= closeRange)
            {
                reticle.color = Color.red;
            }
            else if (_playerCameraController.TargetDistance <= midRange)
            {
                reticle.color = Color.yellow;
            }
            else
            {
                reticle.color = Color.green;
            }
        }

        private void UpdateDistanceText()
        {
            distanceText.text = _playerCameraController.TargetDistance.ToString("#.00");
            distanceText.color = reticle.color;
        }
    }
}