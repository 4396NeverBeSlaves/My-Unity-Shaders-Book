Shader "Chapter 12/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _bloomTex("Texture",2D) = "white" {}
        _luminanceThreshold("luminanceThreshold",Float) =0.6
        _blurSize("blurSize",Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZTest Always
        ZWrite Off
        Cull Off

        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float2 _MainTex_TexelSize;
        sampler2D _bloomTex;
        float _luminanceThreshold;
        float _blurSize;

        struct v2fLuminance{
            float4 vertex: SV_POSITION;
            float2 uv: TEXCOORD0;
        };

        v2fLuminance vertLuminance(appdata_img v){
            v2fLuminance o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        float luminance(fixed3 color){
            return color.r * 0.2125+ color.g * 0.7154 + color.b * 0.0721;
        }

        fixed4 fragLuminance(v2fLuminance i):SV_TARGET{
            fixed3 color =tex2D(_MainTex,i.uv).rgb;
            float factor = clamp(luminance(color)-_luminanceThreshold ,0,1);

            return fixed4(factor*color,1.0);
        }
        

        struct v2fBloom{
            float4 vertex: SV_POSITION;
            float4 uv: TEXCOORD0;
        };

        v2fBloom vertBloom(appdata_img v){
            v2fBloom o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;
            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0.0)
                o.uv.w = 1-o.uv.w;
            #endif
            
            return o;
        }

        fixed4 fragBloom(v2fBloom i): SV_TARGET{
            return tex2D(_MainTex,i.uv.xy) + tex2D(_bloomTex, i.uv.zw);
            //return tex2D(_bloomTex, i.uv.zw);
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vertLuminance
            #pragma fragment fragLuminance
            ENDCG
        }

        UsePass "Chapter 12/GaussianBlur/GAUSSIAN_VERTICALBLUR"

        UsePass "Chapter 12/GaussianBlur/GAUSSIAN_HORIZONTALBLUR"

        pass{
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }
    }
    Fallback Off
}
