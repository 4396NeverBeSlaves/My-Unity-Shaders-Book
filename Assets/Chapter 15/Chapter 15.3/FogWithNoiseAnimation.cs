using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithNoiseAnimation : PostEffectsBase
{
    [SerializeField] Shader shader;

    [SerializeField] float startPos = 0f, endPos = 2.0f;
    [SerializeField] float fogDensity = 1.0f;
    [SerializeField] Color fogColor = Color.white;

    [SerializeField] Texture noiseTexture;
    [SerializeField, Range(0.01f, 0.5f)] float speedX = 1.0f, speedY = 1.0f;
    [SerializeField] float noiseIntensity = 1.0f;



    Material fogMat;
    Camera cam;
    float offsetX = 0f;
    float offsetY = 0f;
    public Material material
    {
        get
        {
            fogMat = CheckShaderAndCreateMaterial(fogMat, shader);
            return fogMat;
        }
    }

    public Camera camera0
    {
        get
        {
            cam = GetComponent<Camera>();
            return cam;
        }
    }
    // Start is called before the first frame update
    void Start()
    {
        camera0.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            Matrix4x4 rayMatrix = Matrix4x4.zero;
            float fov = camera0.fieldOfView;
            float near = camera0.nearClipPlane;
            float far = camera0.farClipPlane;
            float aspect = camera0.aspect;
            float halfHeight = near * Mathf.Tan(Mathf.Deg2Rad * fov * 0.5f);
            float halfWidth = aspect * halfHeight;
            Vector3 forward = camera0.transform.forward;
            Vector3 up = camera0.transform.up;
            Vector3 right = camera0.transform.right;

            Vector3 toNearCenter = forward * near;
            Vector3 centerToTop = up * halfHeight;
            Vector3 centerToRight = right * halfWidth;

            Vector3 topLeft = toNearCenter + centerToTop - centerToRight;
            Vector3 topRight = toNearCenter + centerToTop + centerToRight;
            Vector3 bottomLeft = toNearCenter - centerToTop - centerToRight;
            Vector3 bottomRight = toNearCenter - centerToTop + centerToRight;

            //topLeft.magnitude/near = length /depth;
            float depthToLength = topLeft.magnitude / near;

            rayMatrix.SetRow(0,bottomLeft.normalized * depthToLength);
            rayMatrix.SetRow(1,bottomRight.normalized * depthToLength);
            rayMatrix.SetRow(2,topRight.normalized * depthToLength);
            rayMatrix.SetRow(3,topLeft.normalized * depthToLength);

            material.SetMatrix("_Rays", rayMatrix);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_StartPos",startPos);
            material.SetFloat("_EndPos", endPos);
            material.SetFloat("_FogDensity",fogDensity);

            material.SetTexture("_NoiseTex", noiseTexture);
            material.SetFloat("_OffsetX",offsetX);
            material.SetFloat("_OffsetY",offsetY);
            material.SetFloat("_NoiseIntensity", noiseIntensity);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    // Update is called once per frame
    void Update()
    {
        offsetX = Mathf.Repeat(Time.time * speedX, 1f);
        offsetY = Mathf.Repeat(Time.time * speedY, 1f);
        material.SetFloat("_OffsetX", offsetX);
        material.SetFloat("_OffsetY", offsetY);
    }
}
