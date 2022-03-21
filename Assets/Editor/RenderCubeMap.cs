using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubeMap : ScriptableWizard
{
    [SerializeField] Transform cubePosition;
    [SerializeField] Cubemap cubemap;

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("Cubemap Camera");
        go.AddComponent<Camera>();
        go.transform.position = cubePosition.position;
        go.GetComponent<Camera>().RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }

    private void OnWizardUpdate()
    {
        helpString = "Select Cubemap Position and Cubemap.";
        isValid = cubemap != null && cubePosition != null;
    }

    [MenuItem("GameObject/Render into Cubemap")]
    public static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Render into Cubemap","Render!");
    }
}
