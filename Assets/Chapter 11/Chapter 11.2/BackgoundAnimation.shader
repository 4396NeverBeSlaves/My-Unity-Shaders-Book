Shader "Chapter 11/BackgoundAnimation"
{
     Properties
    {
        _NearTex ("Near Texture", 2D) = "white" {}
        _FarTex("FarTex",2D) = "white" {}
        _NearSpeed("NearSpeed",Float) = 2
        _FarSpeed("FarSpeed",Float) = 1
        _Multiplier("Multiplier",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            Tags{"LightMode"= "ForwardBase"}

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
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _NearTex;
            float4 _NearTex_ST;
            sampler2D _FarTex;
            float4 _FarTex_ST;
            float _NearSpeed;
            float _FarSpeed;
            float _Multiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _NearTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _FarTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float nearOffset = _NearSpeed * _Time.y;
                float farOffset = _FarSpeed * _Time.y;

                float4 nearColor = tex2D(_NearTex, float2(i.uv.x  + nearOffset, i.uv.y));
                float4 farColor = tex2D(_FarTex, float2(i.uv.z + farOffset , i.uv.w ));
                fixed4 color = lerp(farColor, nearColor, nearColor.a) * _Multiplier;
                
                return color;
            }
            ENDCG
        }
    }
}
