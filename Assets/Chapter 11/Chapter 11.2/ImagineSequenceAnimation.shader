Shader "Chapter 11/ImagineSequenceAnimation"
{
    Properties
    {
        _MainTex ("Imagine Sequence", 2D) = "white" {}
        _HorizontalAmount("HorizontalAmount",Range(1,20))=8
        _VerticalAmount("VerticalAmount",Range(1,20))=8
        _Speed("Speed",Float) = 2
        _Color("Color",Color)=(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Tranparent" "Queue"="Transparent" "IgnoreProjector"="True" }
        LOD 100

        Pass
        {
            Tags{"LightMode"= "ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time.y * _Speed;
                float row = floor(time/_HorizontalAmount);
                float column = floor(fmod(time,_VerticalAmount));

                float2 uv = float2(i.uv.x/_HorizontalAmount,i.uv.y/_VerticalAmount);
                uv.x = uv.x + column/_HorizontalAmount;
                uv.y = uv.y + (_VerticalAmount-1.0-row)/_VerticalAmount;
                fixed4 color = tex2D(_MainTex, uv) * _Color;

                return color;
            }
            ENDCG
        }
    }
}
