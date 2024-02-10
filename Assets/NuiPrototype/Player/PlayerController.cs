using System.Collections;
using System.Collections.Generic;
using TMPro;
using Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public class targetInfo
    {
        //am I currently targeting this
        public bool currentTarget;
        //is it an enemy
        public bool isEnemy;
        //the gameobject the camera is actually targeting
        public GameObject targetPoint;
    }

    //character settings
    public float gravity = 3f;
    public float jumpHeight = 5f;
    public float speed = 5f;
    public float rotationSpeed = 90f;

    //components
    public GameObject playerCamera;
    public Transform playerModel;
    public Transform localParent;
    public Transform globalParent;
    public Animator playerAnimator;
    public CharacterController playerController;
    public GameObject targetCamera;
    public GameObject followCamera;
    public GameObject reticleUI;
    public Transform reticleTarget;
    public List<targetInfo> targetList = new List<targetInfo>();

    //skill text fields
    public TMP_Text skillUpText;
    public TMP_Text skillLeftText;
    public TMP_Text skillRightText;
    public TMP_Text skillDownText;
    //actual held skills
    protected AttackClass skillUp;
    protected AttackClass skillLeft;
    protected AttackClass skillRight;
    protected AttackClass skillDown;

    //varibles
    protected bool isGrounded = true;
    protected float verticalSpeed = 0f;
    protected bool canAttack = true;

    //input
    protected Vector2 moveInput;
    protected Vector2 lookInput;
    protected bool attackInput;
    protected bool jumpInput;
    protected bool camInput;
    protected bool targetInput;

    //attack data
    public List<AttackClass> attackData = new List<AttackClass>();

    //cam switch
    public void IsTargeting(InputAction.CallbackContext context)
    {
        if (context.started) 
        {
            camInput = !camInput;
            switchCam();
        }
    }

    //cam switch
    public void SwitchTarget(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            changeTarget();
        }
    }

    //attack input
    public void AttackUp(InputAction.CallbackContext context)
    {
        if (context.started) { attackInput = true; }
    }

    //jump input
    public void Jump(InputAction.CallbackContext context)
    {
        if (context.started) { jumpInput = true; }
    }

    //look input
    public void Look(InputAction.CallbackContext context)
    {
        lookInput = context.ReadValue<Vector2>();
    }

    //move input
    public void Move(InputAction.CallbackContext context)
    {
        moveInput = context.ReadValue<Vector2>();
    }

    //debug input arrow keys to cycle through skills
    public void SwitchSkillDev(InputAction.CallbackContext context)
    {
        if (context.ReadValue<float>() == 1f && !context.started)
        {
            NextAttack();
        } else if (context.ReadValue<float>() == -1f && !context.started)
        {
            PrevAttack();
        }
    }

    void Start()
    {
        createTarget();
    }

    void Update()
    {
        UpdateMovement();
        UpdateAttack();
        UpdateUI();
    }

    //updating target list, should be called on join/leave/die
    void createTarget()
    {
        //clearing list, not sure if needed
        targetList.Clear();

        //loop through targets from tag and add to list
        var possibleTargets = GameObject.FindGameObjectsWithTag("Target");
        for (int i = 0; i < possibleTargets.Length; i++)
        {
            targetInfo obj = new targetInfo();

            //if very first iteration
            if (i == 0)
            {
                //target first found object as target
                obj.currentTarget = true;
                targetCamera.GetComponent<CinemachineVirtualCamera>().LookAt = possibleTargets[i].transform;
                reticleTarget = possibleTargets[i].transform;
            } 
            else
            {
                obj.currentTarget = false;
            }

            obj.isEnemy = true;
            obj.targetPoint = possibleTargets[i];
            targetList.Add(obj);
            Debug.Log("target list added");
        }
        
    }

    void changeTarget()
    {
        //ignore if no target list is there
        if (targetList.Count > 0)
        {
            //loop through possible targets
            for (int i = 0; i < targetList.Count; i++)
            {
                //find the one we are looking at
                if (targetList[i].currentTarget == true)
                {
                    //if taget is last in list, use first one
                    if (i == targetList.Count -1)
                    {
                        targetCamera.GetComponent<CinemachineVirtualCamera>().LookAt = targetList[0].targetPoint.transform;
                        reticleTarget = targetList[0].targetPoint.transform;
                        targetList[0].currentTarget = true;
                        Debug.Log("I chose the first one");
                        targetList[i].currentTarget = false;
                    }
                    //otherwise choose next target in list
                    else
                    {
                        targetCamera.GetComponent<CinemachineVirtualCamera>().LookAt = targetList[i + 1].targetPoint.transform;
                        reticleTarget = targetList[i + 1].targetPoint.transform;
                        targetList[i + 1].currentTarget = true;
                        Debug.Log("I chose the next one");
                        targetList[i].currentTarget = false;
                    }
                    return;
                }
            }
        }
    }

    void switchCam()
    {
        if (camInput)
        {
            //now targeting
            targetCamera.SetActive(true);
            followCamera.SetActive(false);
            reticleUI.SetActive(true);
        } else
        {
            //now following
            targetCamera.SetActive(false);

            //copy transform from target cam onto follow cam
            Vector3 pos = targetCamera.transform.position;
            Quaternion rot = targetCamera.transform.rotation;
            Vector3 scale = targetCamera.transform.localScale;
            followCamera.transform.position = pos;
            followCamera.transform.rotation = rot;
            followCamera.transform.localScale = scale;
            reticleUI.SetActive(false);
            followCamera.SetActive(true);
        }
    }

    // ----------------> Debug Skill Testing
    void NextAttack()
    {
        if (skillUp == null)
        {
            //if no skill is selected start with #1
            skillUp = attackData[0];
            skillUpText.text = attackData[0].attackName;
        } else {
            //get skill id from name
            int currentSkillID = attackData.FindIndex(a => a.attackName.Contains(skillUp.attackName));
            //failsafe so we dont go above the amount of skills we have
            if (currentSkillID < attackData.Count - 1)
            {
                skillUp = attackData[currentSkillID + 1];
                skillUpText.text = attackData[currentSkillID + 1].attackName;
            }
        }

    }

    void PrevAttack()
    {
        if (skillUp == null)
        {
            //if no skill is selected start with #1
            skillUp = attackData[0];
            skillUpText.text = attackData[0].attackName;
        }
        else
        {
            //get skill id from name
            int currentSkillID = attackData.FindIndex(a => a.attackName.Contains(skillUp.attackName));

            //failsafe so we dont go negative
            if (-1 != currentSkillID - 1)
            {
                skillUp = attackData[currentSkillID - 1];
                skillUpText.text = attackData[currentSkillID - 1].attackName;
            }
            
        }

    }
    // ------------------> End Debug

    public void UpdateUI()
    {
        if (camInput)
        {
            Vector3 screenPos = playerCamera.GetComponent<Camera>().WorldToScreenPoint(reticleTarget.position);
            reticleUI.transform.position = screenPos;
        }
        
    }


    public void UpdateMovement()
    {
        // get a normalized directional vector from camera
        Vector3 forward = playerCamera.transform.forward;
        Vector3 right = playerCamera.transform.right;
        forward.y = 0;
        right.y = 0;
        forward = forward.normalized;
        right = right.normalized;

        // multiply with speed and input
        Vector3 camRelativeForward = moveInput.y * forward;
        Vector3 camRelativeRight = moveInput.x * right;
        Vector3 cameraRelativeMovement = camRelativeForward + camRelativeRight;
        cameraRelativeMovement = cameraRelativeMovement.normalized * speed;

        // set rotation and direction before gravity
        float singleStep = rotationSpeed * Time.deltaTime;
        Vector3 newDirection = Vector3.RotateTowards(playerModel.forward, cameraRelativeMovement, singleStep, 0.0f);
        playerModel.rotation = Quaternion.LookRotation(newDirection);
        // gizmo the directional vector
        Debug.DrawRay(playerModel.position, newDirection, Color.red);

        //add gravity
        if (playerController.isGrounded)
        {
            cameraRelativeMovement.y = -gravity * 0.1f;
            verticalSpeed = 0;

            // if clicked attack and allowed to attack 
            if (attackInput == true && canAttack == true)
            {
                if (skillUp != null)
                {
                    ExecuteAttack();
                } else
                {
                    attackInput = false;
                    canAttack = true;
                }
            }

            //jump
            if (jumpInput == true)
            {
                verticalSpeed = jumpHeight;
                cameraRelativeMovement.y = verticalSpeed;
                jumpInput = false;
            }


        }
        else
        {
            // creating acceleration
            verticalSpeed -= gravity * Time.deltaTime;
            cameraRelativeMovement.y = verticalSpeed;
        }

        //finally make character move
        playerController.Move(cameraRelativeMovement * Time.deltaTime * speed);

        // animator set speed and grounded
        playerAnimator.SetFloat("playerSpeed", playerController.velocity.magnitude);
        playerAnimator.SetBool("isGrounded", playerController.isGrounded);
        
    }
    //ATTACK HANDLING
    public void ExecuteAttack()
    {
        //playing the animation
        int currentSkillID = attackData.FindIndex(a => a.attackName.Contains(skillUp.attackName));
        playerAnimator.CrossFade(attackData[currentSkillID].attackAnimation, 0.1f, -1);   
        canAttack = false;
        attackInput = false;
    }

    //animation event object spawn
    public void SpawnObjectLocal(GameObject spawnedObj)
    {
        GameObject currentObj = Instantiate(spawnedObj, localParent, false);
    }

    //animation event object spawn world space
    public void SpawnObjectGlobal(GameObject spawnedObj)
    {
        GameObject currentObj = Instantiate(spawnedObj, localParent, false);
        currentObj.transform.parent = globalParent.transform;
    }

    public void UpdateAttack()
    {

    }

    //releases the character so they are allowed to attack again
    public void AnimationEnd()
    {
        canAttack = true;
    }

}
