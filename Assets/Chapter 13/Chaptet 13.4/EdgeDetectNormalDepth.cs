using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalDepth : PostEffectsBase
{
    [SerializeField] Shader shader;
    [SerializeField, Range(0, 1)] float EdgeOnly = 0.5f;
    [SerializeField] float SamplingArea = 1.0f;
    [SerializeField,Range(0,5)] float NormalSensitivity = 0.5f;
    [SerializeField,Range(0,1)] float DepthSensitivity = 0.5f;
    [SerializeField] Color EdgeColor = Color.black;
    [SerializeField] Color BackgroundColor = Color.white;
    

    Material mat;

    Material material
    {
        get
        {
            mat = CheckShaderAndCreateMaterial(mat, shader);
            return mat;
        }
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_EdgeOnly", EdgeOnly);
            material.SetFloat("_SamplingArea", SamplingArea);
            material.SetFloat("_NormalSensitivity", NormalSensitivity);
            material.SetFloat("_DepthSensitivity", DepthSensitivity);
            material.SetColor("_EdgeColor", EdgeColor);
            material.SetColor("_BackgroundColor", BackgroundColor);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
