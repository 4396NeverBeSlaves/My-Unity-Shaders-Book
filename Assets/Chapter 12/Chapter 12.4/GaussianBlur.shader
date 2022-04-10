Shader "Chapter 12/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _blurSize("blurSize", Float) = 1.0
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
        float2 _MainTex_TexelSize;
        float _blurSize;

        v2f vertVerticalBlur (appdata_img v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.texcoord + _MainTex_TexelSize * float2(0,-2) * _blurSize; 
            o.uv[1] = v.texcoord + _MainTex_TexelSize * float2(0,-1) * _blurSize;
            o.uv[2] = v.texcoord + _MainTex_TexelSize * float2(0,0) * _blurSize;
            o.uv[3] = v.texcoord + _MainTex_TexelSize * float2(0,1) * _blurSize;
            o.uv[4] = v.texcoord + _MainTex_TexelSize * float2(0,2) * _blurSize;
            return o;
        }

        v2f vertHorizontalBlur (appdata_img v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.texcoord + _MainTex_TexelSize * float2(-2, 0) * _blurSize; 
            o.uv[1] = v.texcoord + _MainTex_TexelSize * float2(-1, 0) * _blurSize;
            o.uv[2] = v.texcoord + _MainTex_TexelSize * float2(0, 0) * _blurSize;
            o.uv[3] = v.texcoord + _MainTex_TexelSize * float2(1, 0) * _blurSize;
            o.uv[4] = v.texcoord + _MainTex_TexelSize * float2(2, 0) * _blurSize;
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            float blurFactors[3] = {0.4026, 0.2442, 0.0545};
            fixed3 sum = tex2D(_MainTex, i.uv[2]).rgb * blurFactors[0];
            for(int it =1; it < 3; it++){
                sum += tex2D(_MainTex, i.uv[2 - it]).rgb * blurFactors[it];
                sum += tex2D(_MainTex, i.uv[2 + it]).rgb * blurFactors[it];
            }
            return fixed4(sum,1.0);
        }
        ENDCG

        Pass
        {
            Name "GAUSSIAN_VERTICALBLUR"
            ZTest Always
            Zwrite Off
            Cull Off
            CGPROGRAM
            #pragma vertex vertVerticalBlur
            #pragma fragment frag
            ENDCG
        }

                Pass
        {
            Name "GAUSSIAN_HORIZONTALBLUR"
            ZTest Always
            Zwrite Off
            Cull Off
            CGPROGRAM
            #pragma vertex vertHorizontalBlur
            #pragma fragment frag
            ENDCG
        }
    }
    Fallback Off
}
