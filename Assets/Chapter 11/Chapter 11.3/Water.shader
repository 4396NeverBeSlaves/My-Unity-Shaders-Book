Shader "Chapter 11/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Magnitude("Magnitude",Float) = 1.0
        _Frequency("Frequency", Float) = 1.0
        _DirectionOffset("DirectionOffset", Float) =10.0
        _FlowSpeed("FlowSpeed", Float) = 1.0
        _Color("Color", Color)=(1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"= "Transparent" "IgnoreProjector"="True"  "DisableBatching"="True"}
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

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
            float _DirectionOffset;
            float _Frequency;
            float _Magnitude;
            float _FlowSpeed;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                float4 offset = float4(0,0,0,0);
                offset.y = _Magnitude* sin(2*3.14159265*_Frequency *_Time.y + (v.vertex.x + v.vertex.y + v.vertex.z)* _DirectionOffset);
                

                o.vertex = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.x += _FlowSpeed * _Time.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv) * _Color;
            }
            ENDCG
        }
    }
}
