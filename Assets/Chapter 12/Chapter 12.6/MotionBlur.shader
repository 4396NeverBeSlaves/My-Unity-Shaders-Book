Shader "Chapter 12/MotionBlure"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _blurFactor("blurFactor",Float) = 0.5
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
        float _blurFactor;
        
        struct v2f{
            float4 vertex: SV_POSITION;
            float2 uv: TEXCOORD0;
        };

        v2f vert(appdata_img v){
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed4 fragRGB(v2f i): SV_TARGET{
            return fixed4(tex2D(_MainTex,i.uv).rgb,_blurFactor);
        }

        fixed4 fragA(v2f i): SV_TARGET{
            return tex2D(_MainTex,i.uv);
        }
        ENDCG

        pass{
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB
            ENDCG
        }
        
        pass{
            Blend One Zero
            ColorMask A
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA
            ENDCG
        }
    }
}
