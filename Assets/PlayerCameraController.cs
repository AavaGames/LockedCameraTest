using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using StarterAssets;
using TMPro;

public class PlayerCameraController : MonoBehaviour
{
    public enum SortingType { List, Distance }

    private bool _targetting = false;
    public CinemachineVirtualCamera defaultCamera;
    public CinemachineVirtualCamera[] targettingCameras;
    private int currentTargettingCamera = 0;

    private ThirdPersonController controller;

    public GameObject currentTarget;
    public List<GameObject> possibleTargets = new List<GameObject>();
    private int _targetIndex = -1;

    public UnityEngine.UI.Image Reticle;
    public TextMeshProUGUI distanceText;
    public TextMeshProUGUI sortingLabel;
    private float _targetDistance = 0f;
    public float TargetDistance => _targetDistance;

    [Header("Variables")]
    public SortingType sortingType;
    [Tooltip("How high to position the camera above the player's feet/origin")]
    public float playerHeightOffset = 1.375f;
    public float cameraDistance = 3.0f;

    void Start()
    {
        controller = GetComponent<ThirdPersonController>();
        Reticle.enabled = false;
        distanceText.enabled = false;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            _targetting = !_targetting;

            if (currentTarget == null)
                FindTarget(true);

            CinemachineVirtualCamera cam;
            if (_targetting)
            {
                cam = targettingCameras[currentTargettingCamera];
            }
            else
            {
                controller.CameraLookAt(currentTarget.transform);
                cam = defaultCamera;
            }
            Reticle.enabled = _targetting;
            if (sortingType == SortingType.Distance)
                distanceText.enabled = _targetting;
            ChangeCamera(cam);
        }

        if (Input.GetKeyDown(KeyCode.R))
        {
            if (_targetting)
            {
                controller.CameraLookAt(currentTarget.transform);
                ChangeCamera(defaultCamera);
                _targetting = false;
                Reticle.enabled = false;
                distanceText.enabled = false;
            }

            currentTarget = null;

            if (sortingType == SortingType.Distance)
                sortingType = SortingType.List;
            else
                sortingType = SortingType.Distance;
        }

        sortingLabel.text = sortingType.ToString();

        if (_targetting)
        {
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                FindTarget(false);
            }
            else if (Input.GetKeyDown(KeyCode.Alpha3))
            {
                FindTarget(true);
            }

            UpdateTargetingCameraPosition();
            _targetDistance = Vector3.Distance(transform.position, currentTarget.transform.position);
            distanceText.text = _targetDistance.ToString("#.00");
        }  
    }

    private void FindTarget(bool forward)
    {
        if (possibleTargets.Count < 1)
        {
            Debug.LogError("No targets in list");
            _targetting = false;
            return;
        }

        if (sortingType == SortingType.List)
        {
            if (_targetIndex == -1 || currentTarget == null)
            {
                _targetIndex = 0;
            }
            else
            {
                int index = _targetIndex;
                if (forward)
                    index++;
                else
                    index--;
                _targetIndex = WrapIndex(index, possibleTargets.Count);
            }
        }
        else if (sortingType == SortingType.Distance)
        {
            List<float> distances = new List<float>(possibleTargets.Count);
            Vector3 pos = transform.position; // speeds up loop
            float currentTargetDistance = 0;

            for (int i = 0; i < possibleTargets.Count; i++)
            {
                // Can be further optimized by skipping square root
                float distance = Vector3.Distance(pos, possibleTargets[i].transform.position);
                distances.Add(distance);

                if (i == _targetIndex)
                    currentTargetDistance = distance;
            }

            List<float> originalDistances = new List<float>(distances);
            distances.Sort();

            int index;
            if (_targetIndex == -1 || currentTarget == null)
            {
                index = 0;
            }
            else
            {
                // Find index of current target in sorted distances
                index = distances.IndexOf(currentTargetDistance); 
                if (forward)
                    index++;
                else
                    index--;
                index = WrapIndex(index, distances.Count);
            }
            // Find new target in the original index position
            _targetIndex = originalDistances.IndexOf(distances[index]);
        }

        currentTarget = possibleTargets[_targetIndex];
        // smooth quickly changing targets
        targettingCameras[currentTargettingCamera].transform.position = Camera.main.transform.position;
        currentTargettingCamera = WrapIndex(currentTargettingCamera + 1, targettingCameras.Length);
        ChangeCamera(targettingCameras[currentTargettingCamera]);
    }

    public float targetDistance;

    public int WrapIndex(int index, int arrayLength) 
    {
        if (index >= arrayLength)
        {
            index -= arrayLength;
            return WrapIndex(index, arrayLength);
        }
        else if (index < 0)
        {
            index += arrayLength;
            return WrapIndex(index, arrayLength);
        }
        return index;
    }

    private void ChangeCamera(CinemachineVirtualCamera cam)
    {
        cam.Priority = 10;
        cam.MoveToTopOfPrioritySubqueue();
    }


    private void UpdateTargetingCameraPosition()
    {
        var player = new Vector3(transform.position.x, transform.position.y + playerHeightOffset, transform.position.z);
        var target = currentTarget.transform.position;

        var heading = target - player;
        var distance = heading.magnitude;
        var direction = heading / distance; // This is now the normalized direction

        var position = player - (direction * cameraDistance);

        targettingCameras[currentTargettingCamera].LookAt = currentTarget.transform;
        targettingCameras[currentTargettingCamera].transform.position = position;
    }
}
