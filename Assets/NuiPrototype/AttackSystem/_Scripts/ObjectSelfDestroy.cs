using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSelfDestroy : MonoBehaviour
{
    public float destroyAfter = 5;
    // Start is called before the first frame update
    void Start()
    {
        Destroy(gameObject, destroyAfter);
    }
}
