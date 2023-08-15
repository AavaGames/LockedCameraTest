using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class PlayerCameraController : MonoBehaviour
{
    private int _currentCamera = 0;
    public CinemachineVirtualCamera Camera0;
    public CinemachineVirtualCamera Camera1;
    public CinemachineVirtualCamera Camera2;
    public CinemachineVirtualCamera Camera3;
    private List<CinemachineVirtualCamera> _cameras = null;

    public GameObject Target1;
    public GameObject Target2;
    public GameObject Target3;
    private List<GameObject> _targets = null;

    public UnityEngine.UI.Image Reticle;

    void Start()
    {
        Reticle.enabled = false;

        _cameras = new List<CinemachineVirtualCamera>
        {
            Camera0,
            Camera1,
            Camera2,
            Camera3,
        };

        _targets = new List<GameObject>
        {
            Target1,
            Target2,
            Target3,
        };
    }

    void Update()
    {
        for (int i = 0; i < 3; i++)
        {
            UpdateTargetingCameraPosition(_targets[i], _cameras[i + 1]);
        }

        if (Input.GetKeyDown(KeyCode.Tab))
        {
            _currentCamera++;
            if (_cameras.Count == _currentCamera)
            {
                _currentCamera = 0;
            }

            Reticle.enabled = _currentCamera > 0;

            _cameras[_currentCamera].Priority = 10;

            _cameras[_currentCamera].MoveToTopOfPrioritySubqueue();
        }
    }

    private void UpdateTargetingCameraPosition(GameObject targetPlayer, CinemachineVirtualCamera camera)
    {
        float playerHeightOffset = 1.375f; // How high to position the camera above the player's feet/origin
        var player = new Vector3(this.transform.position.x, this.transform.position.y + playerHeightOffset, this.transform.position.z);
        var target = targetPlayer.transform.position;

        var heading = target - player;
        var distance = heading.magnitude;
        var direction = heading / distance; // This is now the normalized direction.

        int cameraSetback = 3; // How far to set the camera back behind player
        var position = player - (direction * cameraSetback);

        //Debug.DrawLine(player, position, Color.cyan);

        camera.transform.position = position;
    }
}
