Shader "Chapter 12/BrightSaturationContrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _brightness("Brightness",Float)=1.0
        _saturation("Saturation",Float)=1.0
        _contrast("Contrast",Float)=1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _brightness;
            float _saturation;
            float _contrast;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 finalColor = col.rgb * _brightness;

                float luminance = finalColor.r * 0.2125+ finalColor.g * 0.7154 + finalColor.r * 0.0721;
                
                finalColor = lerp(fixed3(luminance,luminance,luminance),finalColor,_saturation);

                finalColor = lerp(fixed3(0.5, 0.5, 0.5), finalColor,_contrast);

                return fixed4(finalColor,1.0);
            }
            ENDCG
        }
    }
}
