using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase
{
    [SerializeField] Shader shader;
    [SerializeField, Range(0.1f, 3.0f)] float blurSize = 1.0f;
    [SerializeField, Range(1, 10)] int iterations = 1;
    [SerializeField, Range(0.1f, 3.0f)] float luminanceThreshold = 0.6f;

    Material mat = null;
    Material material
    {
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
            material.SetFloat("_blurSize", blurSize);
            material.SetFloat("_luminanceThreshold", luminanceThreshold);

            int rtW = source.width;
            int rtH = source.height;
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH);
            RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH);

            Graphics.Blit(source, rt0, material, 0);
            //Graphics.Blit(rt0, destination);

            for (int i = 0; i < iterations; i++)
            {
                Graphics.Blit(rt0, rt1, material, 1);
                Graphics.Blit(rt1, rt0, material, 2);
            }

            material.SetTexture("_bloomTex", rt0);
            Graphics.Blit(source, destination, material, 3);

            RenderTexture.ReleaseTemporary(rt0);
            RenderTexture.ReleaseTemporary(rt1);
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
