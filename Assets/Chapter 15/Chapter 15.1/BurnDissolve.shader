Shader "Chapter 15/BurnDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("BumpMap", 2D) = "bump" {}
        _BurnMap ("BurnMap", 2D) = "white" {}
        _BurnProgress("BurnProgress",Range(0,1)) = 0.5
        _BurnLineWidth("BurnLineWidth", float) = 0.2
        _FirstBurnColor("FirstBurnColor", Color) = (1.0,1.0,1.0,1.0)
        _SecondBurnColor("SecondBurnColor", Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase" "Queue"="AlphaTest"}
            Cull OFF
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float2 uvBurn : TEXCOORD1;
                SHADOW_COORDS(2)
                float3 lightTan : TEXCOORD3;
                float4 worldPos : TEXCOORD4;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            float _BurnProgress;
            float _BurnLineWidth;
            fixed4 _FirstBurnColor;
            fixed4 _SecondBurnColor;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurn = TRANSFORM_TEX(v.texcoord, _BurnMap);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                float3 light = ObjSpaceLightDir(v.vertex);
                TANGENT_SPACE_ROTATION;
                o.lightTan = mul(rotation, light);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float burnNoise = tex2D(_BurnMap, i.uvBurn).r;
                clip(burnNoise - _BurnProgress);

                float3 normalTan = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = saturate(dot(normalTan, i.lightTan)) * albedo;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 c = ambient + diffuse * atten;

                float lerpFactor = smoothstep(0, _BurnLineWidth, burnNoise - _BurnProgress);
                fixed3 burnColor = lerp(_FirstBurnColor, _SecondBurnColor, lerpFactor);

                fixed3 finalColor = lerp(c, burnColor,(1- lerpFactor) * step(0.001, _BurnProgress));

                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }

        pass{
            Tags{"LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uvBurn : TEXCOORD0;
                V2F_SHADOW_CASTER;
            };

            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            float _BurnProgress;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.uvBurn = TRANSFORM_TEX(v.texcoord, _BurnMap);

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float burnNoise = tex2D(_BurnMap, i.uvBurn).r;
                clip(burnNoise - _BurnProgress);

                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG

        }
    }
}
