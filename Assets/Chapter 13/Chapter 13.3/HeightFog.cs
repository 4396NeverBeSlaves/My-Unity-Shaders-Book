using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeightFog : PostEffectsBase
{
    [SerializeField] Shader shader;
    [SerializeField] float fogIntensity = 1.0f;
    [SerializeField] float fogStart = 0.0f;
    [SerializeField] float fogEnd = 2.0f;
    [SerializeField] Color fogColor;

    Material mat;
    Camera cam;

    Material material
    {
        get
        {
            mat = CheckShaderAndCreateMaterial(mat, shader);
            return mat;
        }
    }

    Camera camera
    {
        get
        {
            if(cam == null)
            {
                cam = GetComponent<Camera>();
                cam.depthTextureMode = DepthTextureMode.Depth;
            }
            return cam;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            float halfHeight = camera.nearClipPlane * Mathf.Tan(Mathf.Deg2Rad * camera.fieldOfView * 0.5f);
            float halfWidth = camera.aspect * halfHeight;

            Vector3 toCenter = camera.transform.forward * camera.nearClipPlane;
            Vector3 centerUp = camera.transform.up * halfHeight; 
            Vector3 centerRight = camera.transform.right * halfWidth;

            Vector3 topLeft = toCenter + centerUp - centerRight;
            Vector3 topRight = toCenter + centerUp + centerRight;
            Vector3 bottomLeft = toCenter - centerUp - centerRight;
            Vector3 bottomRight = toCenter - centerUp + centerRight;

            float depthToDistanceFactor = topLeft.magnitude / Mathf.Abs(camera.nearClipPlane);

            topLeft *= depthToDistanceFactor;
            topRight *= depthToDistanceFactor;
            bottomLeft *= depthToDistanceFactor;
            bottomRight *= depthToDistanceFactor;

            Matrix4x4 rayMatrix = Matrix4x4.zero;
            rayMatrix.SetRow(0,bottomLeft);
            rayMatrix.SetRow(1,bottomRight);
            rayMatrix.SetRow(2,topRight);
            rayMatrix.SetRow(3,topLeft);

            material.SetMatrix("_RayMatrix", rayMatrix);
            material.SetFloat("_FogIntensity", fogIntensity);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);
            material.SetVector("_FogColor", fogColor);

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
