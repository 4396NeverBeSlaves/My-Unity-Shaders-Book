using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    [SerializeField] Shader shader;
    [SerializeField, Range(0, 1)] float edgeOnly;
    [SerializeField] Color edgeColor;
    [SerializeField] Color backgroundColor;

    Material mat = null;

    public Material material {
        get
        {
            mat = CheckShaderAndCreateMaterial(mat, shader);
            return mat;
        }
    } 
 
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_edgeOnly", edgeOnly);
            material.SetVector("_edgeColor", edgeColor);
            material.SetVector("_backgroundColor", backgroundColor);
            Graphics.Blit(source, destination, material, -1);
        }
        else
        { 
            Graphics.Blit(source, destination);
        }
    }

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
