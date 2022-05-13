Shader "Chapter 15/WaterWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bumpmap("Bumpmap", 2D) = "bump"{}
        _ReflectCubemap("ReflectCubemap", Cube) = "_Skybox"{}
        _OffsetX("OffsetX",float) = 0.5
        _OffsetY("OffsetY",float) = 0.5
        _Distortion("Distortion",Range(1,1000.0)) = 100

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
        
        GrabPass{"_GrabTex"}

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 TW0 : TEXCOORD1;
                float4 TW1 : TEXCOORD2;
                float4 TW2 : TEXCOORD3;
                float4 scrPos : TEXCOORD4; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bumpmap;
            float4 _Bumpmap_ST;
            samplerCUBE _ReflectCubemap;
            sampler2D _GrabTex;
            float4 _GrabTex_TexelSize;
            float _OffsetX;
            float _OffsetY;
            float _Distortion;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _Bumpmap);

                float3 normal = normalize(v.normal);
                float3 tangent = normalize(v.tangent.xyz);
                float3 bintangent = normalize(cross(normal, tangent)) * v.tangent.w * unity_WorldTransformParams.w;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.TW0 = float4(tangent.x, bintangent.x, normal.x, worldPos.x);
                o.TW1 = float4(tangent.y, bintangent.y, normal.y, worldPos.y);
                o.TW2 = float4(tangent.z, bintangent.z, normal.z, worldPos.z);

                o.scrPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TW0.w, i.TW1.w, i.TW2.w);
                float3 view = normalize(UnityWorldSpaceViewDir(worldPos));
                float2 offset = float2(_OffsetX, _OffsetY); 
                float3 bump0 = UnpackNormal(tex2D(_Bumpmap, i.uv.zw + offset));
                float3 bump1 = UnpackNormal(tex2D(_Bumpmap, i.uv.zw - offset));
                float3 normalTanSpace = normalize(bump0 + bump1);

                i.scrPos.xy += normalTanSpace.xy * _Distortion * _GrabTex_TexelSize.xy;
                fixed3 refractColor = tex2D(_GrabTex, i.scrPos.xy/i.scrPos.w).rgb;

                float3 normalWorldSpace = float3(dot(i.TW0.xyz,normalTanSpace), dot(i.TW1.xyz,normalTanSpace), dot(i.TW2.xyz,normalTanSpace));
                float3 reflectDir = reflect(-view, normalWorldSpace);
                fixed3 reflectColor = texCUBE(_ReflectCubemap, reflectDir).rgb * tex2D(_MainTex, i.uv.xy + offset).rgb;

                float frenel = pow(1 - saturate(dot(view, normalWorldSpace)), 2);
                return fixed4(refractColor * (1 - frenel) + reflectColor * frenel, 1.0);
                // return fixed4( reflectColor, 1.0);

            }
            ENDCG
        }
    }
}
