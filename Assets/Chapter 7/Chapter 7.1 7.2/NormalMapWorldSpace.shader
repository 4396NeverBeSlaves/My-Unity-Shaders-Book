Shader "Chapter 7/NormalMapWorldSpace"{
    Properties{
        _MainTex("Albedo", 2D)="white"{}
        _BumpMap("BumpMap", 2D)="bump"{}
        _BumpScale("BumpScale", Float) = 1
        _Color("Color", Color)=(1.0,1.0,1.0,1.0)
        _Specular("Specular", Color)=(1.0,1.0,1.0,1.0)
        _Gloss("Gloss", Float)= 20
    }

    SubShader{
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
                float3 tangent2WorldV0 : TEXCOORD0;
                float3 tangent2WorldV1 : TEXCOORD1;
                float3 tangent2WorldV2 : TEXCOORD2;
                float4 worldPosition : TEXCOORD3;
                float4 uv : TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            float _BumpScale;
            float4 _Color;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex.xyz);
                o.uv.xy = v.texcoord.xy *_MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy *_BumpMap_ST.xy + _BumpMap_ST.zw;

                o.worldPosition = mul(unity_ObjectToWorld ,v.vertex);

                float3 normal = normalize(UnityObjectToWorldNormal(v.normal));
                float3 tangent = normalize(UnityObjectToWorldNormal(v.tangent.xyz));
                float3 bitangent = cross(normal, tangent)*v.tangent.w;
                float3x3 tbn= transpose(float3x3(tangent, bitangent, normal));

                o.tangent2WorldV0=float3(tbn[0]);
                o.tangent2WorldV1=float3(tbn[1]);
                o.tangent2WorldV2=float3(tbn[2]);
                
                return o;
            }

            fixed4 frag(v2f i): SV_TARGET{
                float3x3 tbn= float3x3(i.tangent2WorldV0,i.tangent2WorldV1,i.tangent2WorldV2);

                float3 normal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                normal.xy = normal.xy * _BumpScale;
                normal.z = sqrt(1-saturate(dot(normal.xy,normal.xy)));
                normal = normalize(mul(tbn,normal));

                float3 light = normalize(WorldSpaceLightDir(i.worldPosition));
                float3 view = normalize(WorldSpaceViewDir(i.worldPosition));
                float3 half_vec = normalize(view+light);
                
                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient= albedo * UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(light,normal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(half_vec, normal)),_Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            } 

            ENDCG
        }
    }
    Fallback "Specular"
}