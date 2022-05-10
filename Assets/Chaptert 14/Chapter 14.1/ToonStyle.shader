Shader "Chapter 14/ToonStyle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _RampTex("RampTex", 2D) = "white"{}
        _OutlineSize("OutlineSize",Range(0,1)) = 0.5
        _OutlineColor("OutlineColor", Color) = (0.0, 0.0, 0.0, 1.0)
        _SpecularSize("SpecularSize", Range(0,1)) = 1.0
        _SpecularColor("SpecularColor", Color) = (1.0, 1.0, 1.0, 1.0)
        _HalfLambertAlpha("HalfLambertAlpha",Range(-1,1))= 0.5
        _HalfLambertBeta("HalfLambertBeta",Range(-1,1))= 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "OUTLINE"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _OutlineColor;
            float _OutlineSize;

            v2f vert (appdata_base v)
            {
                v2f o;

                float3 normal = UnityWorldToViewPos(UnityObjectToWorldNormal(v.normal));
                normal.z = -0.5;
                normal = normalize(normal);
                
                o.pos = float4( UnityObjectToViewPos(v.vertex), 1.0);
                o.pos.xyz += normal * _OutlineSize * 0.1;
                o.pos = UnityViewToClipPos(o.pos);
                o.uv = v.texcoord;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        pass{
            Tags {"LightMode"="ForwardBase"}
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityLightingCommon.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) 
                float3 worldPos : TEXCOORD2;
                float3 worldNormal : NORMAL;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RampTex;
            fixed4 _Color;
            fixed4 _SpecularColor;
            float _SpecularSize;
            float _HalfLambertAlpha;
            float _HalfLambertBeta;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 view = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 light = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 normal = normalize(i.worldNormal);
                float3 halfvec = normalize(view + light);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
                float rampTextureUV = (dot(light, normal) * _HalfLambertAlpha + _HalfLambertBeta) * atten;
                fixed3 diffuse = tex2D(_RampTex, float2(rampTextureUV,rampTextureUV)).rgb * albedo.rgb * _LightColor0.rgb;
                float specDot = dot(halfvec, normal);
                float smoothEdgeThreshhold = fwidth(specDot);
                fixed3 specular = lerp(0, 1, smoothstep(-smoothEdgeThreshhold, smoothEdgeThreshhold, specDot + _SpecularSize -1)) * _SpecularColor.rgb;

                return  fixed4(ambient + diffuse + specular, 1.0);;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
