using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterWaveAnimation : MonoBehaviour
{
    [SerializeField, Range(0.01f, 1f)] float speedX = 0.1f;
    [SerializeField, Range(0.01f, 1f)] float speedY = 0.1f;
    [SerializeField, Range(0f, 500f)] float distortion = 100f;
    [SerializeField] Material mat;

    float offsetX = 0f;
    float offsetY = 0f;
    // Start is called before the first frame update
    void Start()
    {
        if(mat == null)
        {
            mat = GetComponent<MeshRenderer>().material;
            if(mat.shader.name != "Chapter 15/WaterWave")
            {
                mat = null;
                this.enabled = false;
            }
            else
            {
                mat.SetFloat("_OffsetX", offsetX);
                mat.SetFloat("_OffsetY", offsetY);
                mat.SetFloat("_Distortion", distortion);
            }
        }

    }

    // Update is called once per frame
    void Update()
    {
        offsetX = Mathf.Repeat(Time.time * speedX, 1);
        offsetY = Mathf.Repeat(Time.time * speedY, 1);
        mat.SetFloat("_OffsetX", offsetX);
        mat.SetFloat("_OffsetY", offsetY);

        mat.SetFloat("_Distortion", distortion);
    }
}
