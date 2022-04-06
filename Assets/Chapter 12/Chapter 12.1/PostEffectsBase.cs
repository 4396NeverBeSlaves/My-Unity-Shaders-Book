using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    bool CheckSupported()
    {
        if(!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures)
        {
            Debug.LogWarning("This platform doesn't image effects or render textures!");
            return false;
        }
        return true;
    }

    void NotSupported()
    {
        enabled = false;
    }
    void CheckResources()
    {
        bool isSupported = CheckSupported();

        if (!isSupported)
        {
            NotSupported();
        }

    }

    protected Material CheckShaderAndCreateMaterial(Material mat, Shader shader)
    {
        if(mat!= null && shader!=null && mat.shader == shader)
        {
            return mat;
        }

        if (shader == null)
        {
            return null;
        }
        if (shader.isSupported)
        {
            Material m = new Material(shader);
            m.hideFlags = HideFlags.DontSave;
            if (m != null)
                return m;
            else
                return null;
        }
        else
        {
            return null;
        }

    }
    // Start is called before the first frame update
    void Start()
    {
        CheckResources();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
