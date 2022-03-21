Shader "TestMatrixLayout"{
    Properties{
        _MainTex("Albedo", 2D)="white"{}
    }

    SubShader{
        pass{
            Tags{"LightMode"= "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCg.cginc"

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 testColor : Color;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex.xyz);

                float3 normal = normalize(v.normal);
                float3 tangent = normalize(v.tangent.xyz);
                float3 bitangent = cross(normal, tangent)*v.tangent.w;
                float3x3 tbn= float3x3(tangent, bitangent, normal);

                o.testColor = mul(tbn, tangent);
                return o;
            }

            fixed4 frag(v2f i): SV_TARGET{
                return fixed4(i.testColor, 1.0);
            } 

            ENDCG
        }
    }
    Fallback "Specular"
}