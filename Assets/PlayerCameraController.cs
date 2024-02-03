using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using UnityEditor.PackageManager;
using UnityEngine.Rendering;
using StarterAssets;
using UnityEngine.InputSystem.XR;
using TMPro;
using UnityEngine.UIElements;
using Unity.VisualScripting;
using System;
using System.Linq;
using UnityEngine.Windows;
using Input = UnityEngine.Input;

public class PlayerCameraController : MonoBehaviour
{
    public enum SortingType { List, Distance }

    private bool _targeting = false;
    public CinemachineVirtualCamera defaultCamera;

    private ThirdPersonController controller;
    private StarterAssetsInputs _input;

    public GameObject currentTarget;
    public List<GameObject> possibleTargets = new List<GameObject>();
    private int _targetIndex = -1;

    public UnityEngine.UI.Image Reticle;
    public TextMeshProUGUI distanceText;
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
        _input = GetComponent<StarterAssetsInputs>();
        Reticle.enabled = false;
        distanceText.enabled = false;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            _targeting = !_targeting;

            if (currentTarget == null)
                FindTarget(true);

            Reticle.enabled = _targeting;
            distanceText.enabled = _targeting;
        }

        if (_targeting)
        {
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                FindTarget(false);
            }
            else if (Input.GetKeyDown(KeyCode.Alpha3))
            {
                FindTarget(true);
            }

            if (_input.look.magnitude < 0.01f)
            {
                controller.CameraLookAt(currentTarget.transform);
            }
            _targetDistance = Vector3.Distance(transform.position, currentTarget.transform.position);
            distanceText.text = _targetDistance.ToString("#.00");
        }  
    }

    private void FindTarget(bool forward)
    {
        if (possibleTargets.Count < 1)
        {
            Debug.LogError("No targets in list");
            _targeting = false;
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
    }

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
}
