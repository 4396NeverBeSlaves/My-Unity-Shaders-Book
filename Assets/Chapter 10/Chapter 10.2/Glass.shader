Shader "Chapter 10/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("BumpMap",2D)="bump"{}
        _BumpScale("BumpScale",Float)=1.0
        _Cubemap("Cubemap",Cube)="_Skybox"{}
        _DistortionAmount("DistortionAmount",Float)=1.0
        _RefractionAmount("RefractionAmount",Range(0,1.0))=1.0
    }
     SubShader{
        Tags{"Queue"="Transparent" "RenderType"="Opaque"}

        GrabPass{"_RefractionTex"}

        pass{
            Tags{"LightMode"= "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCg.cginc"
            #include "Lighting.cginc"

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            sampler2D _RefractionTex;
            samplerCUBE _Cubemap;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            float _BumpScale;
            float _DistortionAmount;
            fixed _RefractionAmount;
            float4 _RefractionTex_TexelSize;

            uniform float3x3 tbn;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex.xyz);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv.xy = v.texcoord.xy *_MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy *_BumpMap_ST.xy + _BumpMap_ST.zw;
                o.screenPos = ComputeGrabScreenPos(o.pos);
                
                float3 normal = normalize(v.normal);
                float3 tangent = normalize(v.tangent.xyz);
                float3 bitangent = cross(normal, tangent)*v.tangent.w;
                tbn= float3x3(tangent, bitangent, normal);

                return o;
            }

            fixed4 frag(v2f i): SV_TARGET{
                float3 viewWorld = UnityWorldSpaceViewDir(i.worldPos);
                float3 lightWorld = UnityWorldSpaceLightDir(i.worldPos);
                

                float3 normal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                normal.xy = normal.xy * _BumpScale;
                normal.z = sqrt(1-saturate(dot(normal.xy,normal.xy)));
                normal = normalize(normal);
                
                float2 offset =-normal.xy * _DistortionAmount * _RefractionTex_TexelSize.xy;
                i.screenPos.xy = i.screenPos.xy + offset;
                float3 refractionColor = tex2D(_RefractionTex,i.screenPos.xy/i.screenPos.w);
                  
                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb;
                fixed3 ambient= albedo * UNITY_LIGHTMODEL_AMBIENT.rgb;

                float3 reflectionDir = reflect(-viewWorld, mul(normal,tbn));
                float3 reflectionColor = texCUBE(_Cubemap,reflectionDir );

                return fixed4(ambient + lerp(reflectionColor , refractionColor,_RefractionAmount), 1.0);
            } 

            ENDCG
        }
    }
    Fallback "Specular"
}
