Shader "Chapter 7/RampTexture"
{
    Properties
    {
        _RampTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color)= (1.0,1.0,1.0,1.0)
        _Specular("Specular", Float) = (1.0,1.0,1.0,1.0)
        _Gloss("Gloss", Float ) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                float4 worldPosition : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _RampTex;
            float4 _RampTex_ST;
            float4 _Color;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RampTex);
                o.worldPosition = mul(unity_ObjectToWorld, o.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 view = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                float3 light = normalize(UnityWorldSpaceLightDir(i.worldPosition));
                float3 half_vec = normalize(view+light);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = dot(light, normal)*0.5 +0.5;
                float3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_RampTex, fixed2(halfLambert,halfLambert)).rgb;

                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(half_vec, normal)),_Gloss); 

                return fixed4((ambient+diffuse+specular), 1.0);
            }
            ENDCG
        }
    }
}
