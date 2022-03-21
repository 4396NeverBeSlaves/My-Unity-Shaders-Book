Shader "Chapter 11/WaterWithShadow"
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
        Tags { "RenderType"="Opaque" "Queue"= "Geometry" }
        LOD 100
        
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            // Blend SrcAlpha OneMinusSrcAlpha
            // Cull Off
            // ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                SHADOW_COORDS(2)
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

                o.pos = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.x += _FlowSpeed * _Time.y;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float atten = SHADOW_ATTENUATION(i);
                
                float4 res = float4(atten, atten, atten, 1.0);
               
                // return res;
                return atten* tex2D(_MainTex, i.uv) * _Color;
            }
            ENDCG
        }

        pass{
            Tags{"LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DirectionOffset;
            float _Frequency;
            float _Magnitude;
            float _FlowSpeed;
            float4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                float4 offset = float4(0,0,0,0);
                offset.y = _Magnitude* sin(2*3.14159265*_Frequency *_Time.y + (v.vertex.x + v.vertex.y + v.vertex.z)* _DirectionOffset);
                v.vertex = v.vertex + offset;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG

        }
    }
    Fallback "VertexLit"
}
