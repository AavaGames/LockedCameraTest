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
        public Canvas PlayerCanvas;
        [Foldout("Dependencies")]
        public Image Reticle;
        [Foldout("Dependencies")]
        public TextMeshProUGUI DistanceText;

        public float CloseRange = 5;
        public float MidRange = 10;

        // Use this for initialization
        void Awake()
        {
            InstanceFinder.TimeManager.OnLateUpdate += TimeManager_OnLateUpdate;

            _playerCameraController = GetComponent<CharacterCamera>();

            PlayerCanvas.enabled = false;
            Reticle.enabled = false;
            DistanceText.enabled = false;
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
                PlayerCanvas.enabled = true;
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
            Reticle.enabled = true;
            DistanceText.enabled = showDistance;
        }

        public void Hide()
        {
            Reticle.enabled = false;
            DistanceText.enabled = false;
        }

        private void UpdateReticle()
        {
            Vector3 screenPosition = Camera.main.WorldToScreenPoint(_playerCameraController.CurrentTarget.transform.position);
            
            // Can switch images because its off the screen to point in direction of target
            screenPosition.x = Mathf.Clamp(screenPosition.x, 0, Screen.width);
            screenPosition.y = Mathf.Clamp(screenPosition.y, 0, Screen.height);
            Reticle.rectTransform.position = screenPosition;

            if (_playerCameraController.TargetDistance <= CloseRange)
            {
                Reticle.color = Color.red;
            }
            else if (_playerCameraController.TargetDistance <= MidRange)
            {
                Reticle.color = Color.yellow;
            }
            else
            {
                Reticle.color = Color.green;
            }
        }

        private void UpdateDistanceText()
        {
            DistanceText.text = _playerCameraController.TargetDistance.ToString("#.00");
            DistanceText.color = Reticle.color;
        }
    }
}