using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightSaturationContrast : PostEffectsBase
{
    [SerializeField]Shader shader;
    [SerializeField, Range(0f, 3f)] float brightness = 1f;
    [SerializeField, Range(0f, 3f)] float saturation = 1f;
    [SerializeField, Range(0f, 3f)] float contrast = 1f;

    Material mat;

    Material material => CheckShaderAndCreateMaterial(mat, shader);
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(mat!= null)
        {
            //Debug.Log("not null");
            mat.SetFloat("_brightness", brightness);
            mat.SetFloat("_saturation", saturation);
            mat.SetFloat("_contrast", contrast);
            Graphics.Blit(source, destination, mat, -1);
        }
        else
        {
            //Debug.Log("null");
            Graphics.Blit(source, destination);
        }

    }
    // Start is called before the first frame update
    void Start()
    {
        mat=this.material;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
