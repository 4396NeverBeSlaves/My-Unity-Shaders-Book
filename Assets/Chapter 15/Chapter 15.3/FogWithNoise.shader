Shader "Chapter 15/FogWithNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 lerpRay : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_TexelSize;
            float4x4 _Rays;
            fixed4 _FogColor;
            float _StartPos;
            float _EndPos;
            float _FogDensity;

            sampler2D _NoiseTex;
            float _OffsetX;
            float _OffsetY;
            float _NoiseIntensity;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                if(o.uv.x < 0.5 && o.uv.y < 0.5){
                    o.lerpRay = _Rays[0];
                }else if(o.uv.x >= 0.5 && o.uv.y < 0.5){
                    o.lerpRay = _Rays[1];
                }else if(o.uv.x >= 0.5 && o.uv.y >= 0.5){
                    o.lerpRay = _Rays[2];
                }else{
                    o.lerpRay = _Rays[3];
                }
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv));
                float3 worldPos = i.lerpRay * depth + _WorldSpaceCameraPos;

                float f = smoothstep(0,1,(_EndPos - worldPos.y)/(_EndPos - _StartPos) * _FogDensity);
                fixed noise = (tex2D(_NoiseTex, i.uv + float2(_OffsetX, _OffsetY)).r * 0.5 + 0.5) * _NoiseIntensity;

                fixed3 finalColor = lerp(tex2D(_MainTex, i.uv).rgb, _FogColor, saturate(f * noise));

                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
