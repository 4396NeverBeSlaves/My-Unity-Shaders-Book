Shader "Chapter 6/HalfLambert"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor("DiffuseColor", Color)=(1.0, 1.0,1.0,1.0)
        _Alpha("Alpha", Float) = 0.5
        _Beta("Beta", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase"}
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                float4 vertex : SV_POSITION;
                fixed3 worldNormal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _DiffuseColor;
            float _Alpha;
            float _Beta;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 light=normalize( _WorldSpaceLightPos0.xyz);
                float3 normal= i.worldNormal;
                fixed4 diffuse = _DiffuseColor * _LightColor0 * (_Alpha * dot(light, normal) + _Beta);
                fixed4 ambient= UNITY_LIGHTMODEL_AMBIENT;
                return fixed4((diffuse + ambient).rgb,1.0);
            }
            ENDCG
        }
    }
}
