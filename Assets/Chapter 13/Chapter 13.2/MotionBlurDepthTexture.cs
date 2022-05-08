using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurDepthTexture : PostEffectsBase
{
    [SerializeField] Shader shader;
    [SerializeField] float BlurSize;

    Camera cam;
    Material mat;
    Matrix4x4 current;

    Material material
    {
        get
        {
            mat = CheckShaderAndCreateMaterial(mat, shader);
            return mat;
        }
    }
    private void OnEnable()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_BlurSize",BlurSize);
            Matrix4x4 previous = current;
            material.SetMatrix("_Previous", previous);
            current = cam.projectionMatrix * cam.worldToCameraMatrix;
            Matrix4x4 currentInverse = current.inverse;
            material.SetMatrix("_CurrentInverse", currentInverse);
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
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
