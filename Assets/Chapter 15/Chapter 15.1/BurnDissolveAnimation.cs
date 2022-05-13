using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BurnDissolveAnimation : MonoBehaviour
{
    [SerializeField] Material mat;
    [SerializeField, Range(0.0f, 1.0f)] float BurnSpeed = 0.5f;

    float BurnProgress = 0f;
    // Start is called before the first frame update
    void Start()
    {
        if (mat == null)
        {
            mat= GetComponentInChildren<MeshRenderer>().material;
            if (mat.shader.name != "Chapter 15/BurnDissolve")
            {
                mat = null;
            }
        }
        if(mat == null)
        {
            this.enabled = false;
        }
        else
        {
            mat.SetFloat("_BurnProgress", BurnProgress);
        }
    }

    // Update is called once per frame
    void Update()
    {
        BurnProgress = Mathf.Repeat(Time.time * BurnSpeed, 1);
        mat.SetFloat("_BurnProgress", BurnProgress);
    }
}
