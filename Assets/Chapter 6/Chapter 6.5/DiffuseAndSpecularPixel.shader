Shader "Chapter 6/DiffuseAndSpecularPixel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1.0,1.0,1.0,1.0)
        _Specular("Specular", Color) = (1.0,1.0,1.0,1.0)
        _Gloss("Gloss", Float) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 localPosition : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.localPosition = v.vertex;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldNormal = i.worldNormal;
                float3 light = normalize(_WorldSpaceLightPos0);
                float3 reflect_light = normalize(reflect(-light, worldNormal));
                float3 view = normalize(WorldSpaceViewDir(i.localPosition));

                fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(light,worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflect_light, view)),_Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
