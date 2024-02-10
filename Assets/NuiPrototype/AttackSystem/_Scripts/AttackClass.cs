using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Data", menuName = "AttackSystem/AttackClass", order = 1)]


public class AttackClass : ScriptableObject
{
    public string attackName;
    public string attackDesc;

    public string schoolType;
    public string capsuleType;

    public bool isComboAttack;
    public string comboInto;

    public string attackAnimation;
}