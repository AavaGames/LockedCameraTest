using NaughtyAttributes;
using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;

namespace Assets.App.Script.Character
{
    public class ReticleController : MonoBehaviour
    {
        private PlayerCameraController _playerCameraController;

        [Foldout("Dependencies")]
        public Image reticle;
        [Foldout("Dependencies")]
        public TextMeshProUGUI distanceText;

        public float closeRange = 5;
        public float midRange = 10;

        // Use this for initialization
        void Awake()
        {
            _playerCameraController = GetComponent<PlayerCameraController>();

            reticle.enabled = false;
            distanceText.enabled = false;
        }

        // Update is called once per frame
        void LateUpdate()
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
            float reticleWidth = reticle.rectTransform.sizeDelta.x;
            float reticleHeight = reticle.rectTransform.sizeDelta.y;

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