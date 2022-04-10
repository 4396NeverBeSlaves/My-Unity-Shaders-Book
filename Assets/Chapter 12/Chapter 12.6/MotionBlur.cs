using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{
    [SerializeField] Shader shader;
    [SerializeField, Range(0.1f, 1.0f)] float blurFactor = 0.5f;


    RenderTexture accumulationTexture = null;
    Material mat = null;

    Material material {
        get {
            mat = CheckShaderAndCreateMaterial(mat, shader);
            return mat;
        }    
    }

    private void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material!= null)
        {
            if(accumulationTexture == null || accumulationTexture.width != source.width || accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = RenderTexture.GetTemporary(source.width, source.height);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
            }

            material.SetFloat("_blurFactor", blurFactor);
            accumulationTexture.MarkRestoreExpected();
            Graphics.Blit(source, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, destination);

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
