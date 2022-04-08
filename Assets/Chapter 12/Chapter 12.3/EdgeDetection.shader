Shader "Chapter 12/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _edgeOnly("edgeOnly",Float) = 0.5
        _edgeColor("edgeColor",Color) = (0,0,0,1)
        _backgroundColor("backgroundColor", Color) = (1,1,1,1)
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
                fixed2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float2 _MainTex_TexelSize;
            float _edgeOnly;
            fixed4 _edgeColor;
            fixed4 _backgroundColor;

            float luminance(fixed3 color){
                return color.r * 0.2125+ color.g * 0.7154 + color.b * 0.0721;
            }

            float sobel(fixed2 uvs[9]){
                half GradxWeight[9]={-1,0,1,
                                -2,0,2,
                                -1,0,1
                };
                half GradyWeight[9]={-1,-2,-1,
                                0,0,0,
                                1,2,1
                };
                float gradx = 0;
                float grady = 0;
                for(int j = 0; j < 9; j++){
                    fixed3 color = tex2D(_MainTex, uvs[j]).rgb;
                    gradx += luminance(color) * GradxWeight[j];
                    grady += luminance(color) * GradyWeight[j];
                }
                float edge = 1 - abs(gradx) - abs(grady);
                return edge;
            }
            
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0]=v.texcoord + _MainTex_TexelSize * fixed2(-1,-1);
                o.uv[1]=v.texcoord + _MainTex_TexelSize * fixed2(0,-1);
                o.uv[2]=v.texcoord + _MainTex_TexelSize * fixed2(1,-1);
                o.uv[3]=v.texcoord + _MainTex_TexelSize * fixed2(-1,0);
                o.uv[4]=v.texcoord + _MainTex_TexelSize * fixed2(0,0);
                o.uv[5]=v.texcoord + _MainTex_TexelSize * fixed2(1,0);
                o.uv[6]=v.texcoord + _MainTex_TexelSize * fixed2(-1,1);
                o.uv[7]=v.texcoord + _MainTex_TexelSize * fixed2(0,1);
                o.uv[8]=v.texcoord + _MainTex_TexelSize * fixed2(1,1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float edge = sobel(i.uv);
                fixed3 color = tex2D(_MainTex, i.uv[4]).rgb;
                // fixed3 colorWithEdge = lerp(_edgeColor.rgb, color, edge);
                // fixed3 colorWithBackground = lerp(color, _backgroundColor.rgb, edge);
                // return fixed4(lerp(colorWithBackground,colorWithEdge,_edgeOnly),1.0);
                
                fixed3 colorWithEdge = lerp(_edgeColor.rgb, color, edge);
                fixed3 edgeAndBackground = lerp(_edgeColor.rgb, _backgroundColor.rgb, edge);
                return fixed4(lerp(colorWithEdge, edgeAndBackground, _edgeOnly),1.0);
            }
            ENDCG
        }
    }
}
