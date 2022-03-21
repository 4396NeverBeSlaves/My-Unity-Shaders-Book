using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GenerateProceduralTexture : MonoBehaviour
{
    public Material material=null;
    #region Material properties
    [SerializeField, SetProperty("textureSize")]
    private int m_textureSize = 512;
    public int textureSize
    {
        get { return m_textureSize; }
        set { m_textureSize = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get { return m_backgroundColor; }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("pointColor")]
    private Color m_pointColor = Color.red;
    public Color pointColor
    {
        get { return m_pointColor; }
        set
        {
            m_pointColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;
    public float blurFactor
    {
        get { return m_blurFactor; }
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }


    void _UpdateMaterial() {
        if (material != null)
        {
            Texture2D m_generateTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generateTexture);
        }
    }

    Color _LerpColor(Color a, Color b, float factor)
    {
        Color c;
        c.r =  Mathf.Lerp(a.r,b.r, factor);
        c.g =  Mathf.Lerp(a.g,b.g, factor);
        c.b =  Mathf.Lerp(a.b,b.b, factor);
        c.a =  Mathf.Lerp(a.a,b.a, factor);
        return c;
    }
    Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTex = new Texture2D(textureSize, textureSize);
        float pointRadius = m_textureSize / 10f;
        float pointsInterval = m_textureSize / 4f;
        float blurRate = 1f / m_blurFactor;

        for (int w = 0; w < m_textureSize; w++)
        {
            for (int h = 0; h < m_textureSize; h++)
            {
                Color pixel = m_backgroundColor;
                Vector2 pixelPos = new Vector2(w, h);
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j< 3; j++)
                    {
                        Vector2 pointCenter = new Vector3((i + 1) * pointsInterval, (j + 1) * pointsInterval);
                        float distance = Vector2.Distance(pointCenter, pixelPos) - pointRadius;
                        float blendRate = Mathf.SmoothStep(0f, 1f, blurRate * distance);
                        pixel = _LerpColor(m_pointColor, pixel, blendRate);
                    }
                }
                proceduralTex.SetPixel(w, h, pixel);
            }
        }
        proceduralTex.Apply();

        return proceduralTex;
    }
    #endregion
    // Start is called before the first frame update
    void Start()
    {
        if (material == null)
        {
            Renderer re = gameObject.GetComponent<Renderer>();
            if (re == null)
            {
                Debug.LogError("Renderer is null!");
            }
            material = re.sharedMaterial;
        }
        _UpdateMaterial();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
