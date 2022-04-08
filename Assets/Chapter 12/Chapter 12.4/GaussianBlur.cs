using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    [SerializeField] Shader shader;
    [SerializeField, Range(1, 16)] int downSample = 1; 
    [SerializeField,Range(0.1f,3.0f)] float blurSize = 1.0f;
    [SerializeField, Range(1, 10)] int iterations = 1;

    Material mat = null;
    Material material
    {
        get {
            mat = CheckShaderAndCreateMaterial(mat, shader);
            return mat;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material!= null)
        {
            material.SetFloat("_blurSize", blurSize);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH);
            RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH);

            Graphics.Blit(source, rt0);

            for(int i = 0; i < iterations; i++)
            {
                Graphics.Blit(rt0,rt1, material,0);
                Graphics.Blit(rt1,rt0, material,1);
            }

            Graphics.Blit(rt0, destination);

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
