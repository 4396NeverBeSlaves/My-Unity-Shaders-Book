Shader "Chapter 13/ShowDepthNormals"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
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
                float3 normal : NORMAL;
                float4 screenPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthNormalsTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = o.vertex;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 scrPos =  ComputeScreenPos(i.screenPos);
                float4 normalsDepth = tex2D(_CameraDepthNormalsTexture,scrPos.xy/scrPos.w);
                float depth;
                float3 normal;

                DecodeDepthNormal(normalsDepth, depth, normal);
                
                return fixed4(normal *0.5 + 0.5, 1.0);
                //return fixed4(depth,depth,depth, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
