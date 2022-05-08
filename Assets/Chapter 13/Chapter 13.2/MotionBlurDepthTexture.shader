Shader "Chapter 13/MotionBlurDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("BlurSize", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite OFF
            ZTest Always
            Cull OFF
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uvDepth : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float4x4 _Previous;
            float4x4 _CurrentInverse;
            float _BlurSize;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uvDepth = v.uv;
                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y<0){
                    o.uvDepth.y = 1-o.uvDepth.y;
                }
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uvDepth);
                float4 currentNDCPos = float4( float3(i.uv.x, i.uv.y, depth) * 2 - 1, 1.0);
                float4 worldPos = mul(_CurrentInverse, currentNDCPos);
                worldPos /= worldPos.w;
                float4 previousNDCPos = mul(_Previous, worldPos);
                previousNDCPos /= previousNDCPos.w;

                float2 motionVector =(currentNDCPos.xy - previousNDCPos.xy) * 0.1;
                float2 uv = i.uv;

                fixed4 sumColor;
                for(uint i = 0; i<10;i++){
                    sumColor += tex2D(_MainTex, uv);
                    uv += motionVector * _BlurSize;
                }
                sumColor /= 10;

                return fixed4(sumColor.rgb, 1.0);
            }
            ENDCG
        }
    }
}
