Shader "Unlit/EdgeDetectNormalDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"

        struct v2f
        {
            float2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _CameraDepthNormalsTexture;
        float _EdgeOnly;
        float _SamplingArea;
        float _NormalSensitivity;
        float _DepthSensitivity;
        fixed4 _EdgeColor;
        fixed4 _BackgroundColor;

        v2f vert (appdata_img v)
        {
            v2f o;
            float2 uv = v.texcoord;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = uv;

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                uv.y = 1 - uv.y;
            }
            #endif
            o.uv[1] = uv + float2(1,1) * _MainTex_TexelSize.xy * _SamplingArea;
            o.uv[2] = uv + float2(-1,-1) * _MainTex_TexelSize.xy * _SamplingArea;
            o.uv[3] = uv + float2(-1,1) * _MainTex_TexelSize.xy * _SamplingArea;
            o.uv[4] = uv + float2(1,-1) * _MainTex_TexelSize.xy * _SamplingArea;
            return o;
        }

        uint calculateSame(float4 sample1, float4 sample2){
            float centerDepth = DecodeFloatRG(sample1.zw);
            float depthDiff = _DepthSensitivity * 500 * abs(centerDepth - DecodeFloatRG(sample2.zw));
            float normalDiff = _NormalSensitivity * length(sample1.xy - sample2.xy);

            uint depthSame = depthDiff * depthDiff >  centerDepth   ? 0 : 1;
            uint normalSame = normalDiff > 0.1 ? 0 : 1;

            return  normalSame * depthSame;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            float4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
            float4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
            float4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
            float4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

            uint edge = calculateSame(sample1, sample2) * calculateSame(sample3, sample4);

            fixed3 edgeAndBackground = lerp(_EdgeColor, _BackgroundColor, edge).rgb;
            fixed3 edgeAndTexture = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge).rgb;

            return fixed4(lerp(edgeAndTexture, edgeAndBackground, _EdgeOnly), 1.0);
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }
}
