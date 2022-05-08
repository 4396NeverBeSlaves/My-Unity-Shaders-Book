Shader "Chapter 13/HeightFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogIntensity("FogIntensity", float) = 1.0
        _FogStart("FogStart", float) =0.0
        _FogEnd("FogEnd", float) = 2.0
        _FogColor("FogColor", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Zwrite OFF
            ZTest Always
            Cull OFF
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float3 ray : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float4x4 _RayMatrix;
            float _FogIntensity;
            float _FogStart;
            float _FogEnd;
            fixed4 _FogColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;
                o.uv.zw = v.uv;

                uint rayIdx = 0;
                if(v.uv.x < 0.5 && v.uv.y <0.5){
                    rayIdx = 0;
                }else if(v.uv.x >= 0.5 && v.uv.y < 0.5){
                    rayIdx = 1;
                }else if(v.uv.x >= 0.5 && v.uv.y >= 0.5){
                    rayIdx = 2;
                }else{
                    rayIdx = 3;
                }

                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0){
                    o.uv.w = 1 - o.uv.w;
                    rayIdx = 3 - rayIdx;
                }
                #endif

                o.ray = _RayMatrix[rayIdx];
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv.zw));
                float3 worldPos = _WorldSpaceCameraPos + i.ray * depth;
                float fogFactor = saturate((_FogEnd - worldPos.y)/(_FogEnd - _FogStart) * _FogIntensity);
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 finalColor = lerp(col, _FogColor, fogFactor);
                return fixed4(finalColor.rgb, 1.0);
            }
            ENDCG
        }
    }
    Fallback OFF
}
