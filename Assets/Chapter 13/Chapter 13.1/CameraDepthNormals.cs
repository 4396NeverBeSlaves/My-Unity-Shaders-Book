using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDepthNormals : MonoBehaviour
{
    private void OnEnable()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
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
