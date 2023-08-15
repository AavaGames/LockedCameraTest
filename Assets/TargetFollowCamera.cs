using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetFollowCamera : MonoBehaviour
{
    public GameObject Player;
    public GameObject Target;
    public CinemachineVirtualCamera Camera;
    private bool display = false;

    void Update()
    {
        //Debug.Log($"Target.transform.position[{Target.transform.position}]; Player.transform.position[{Player.transform.position}]");

        if (Input.GetKeyDown(KeyCode.Tab))
        {
            display = true;
        }

        if (display)
        {
            var target = new Vector3(Target.transform.position.x, 1, Target.transform.position.z);
            var player = new Vector3(Player.transform.position.x, 1, Player.transform.position.z);

            var heading = target - player;
            var distance = heading.magnitude;
            var direction = heading / distance; // This is now the normalized direction.

            Debug.Log($"target[{target}]; player[{player}]; heading[{heading}]");

            Debug.DrawLine(player, heading, Color.cyan);
        }
    }
}
