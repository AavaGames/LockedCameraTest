using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseHomingProjectile : MonoBehaviour
{
    public float projectileSpeed = 5;
    public float rotateSpeed = 2;
    public Rigidbody projectileRB;
    public PlayerController playerController;
    private Vector3 heading;
    void Start()
    {
        playerController = FindObjectOfType<PlayerController>();   
    }

    // Update is called once per frame
    void Update()
    {
        //speed, probably needs to include global speed value from buffs
        projectileRB.velocity = transform.forward * projectileSpeed;

        //rotation, probably needs to include global rotation speed value

        //find currently targeting target
        for (int i = 0; i < playerController.targetList.Count; i++)
        {
            //find the one we are looking at
            if (playerController.targetList[i].currentTarget == true)
            {
                heading = playerController.targetList[i].targetPoint.transform.position - transform.position;
            }
        }
        var rotating = Quaternion.LookRotation(heading);
        projectileRB.MoveRotation(Quaternion.RotateTowards(transform.rotation, rotating, rotateSpeed * Time.deltaTime));
    }
}
