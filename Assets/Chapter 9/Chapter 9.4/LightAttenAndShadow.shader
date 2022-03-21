Shader "Chapter 9/LightAttenAndShadow"
{
        Properties{
        _MainTex("Albedo", 2D)="white"{}
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
            #pragma multi_compile_fwdbase

            #include "UnityCg.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v{
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
                float2 uv : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, float4(v.vertex,1.0));
                o.uv = v.texcoord.xy *_MainTex_ST.xy + _MainTex_ST.zw;
                TRANSFER_SHADOW(o);
                return o;
            }
            
            fixed4 frag(v2f i): SV_TARGET{
                float3 worldNormal = i.worldNormal;
                float3 light = normalize(_WorldSpaceLightPos0);
                float3 view = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                float3 half_vec = normalize(view+light);
                
                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
                fixed3 ambient= albedo * UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(light,worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(half_vec, worldNormal)),_Gloss);
                
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPosition);
                return fixed4(ambient + (diffuse + specular)*atten, 1.0);
            } 
            ENDCG
        }

         pass{
            Tags{"LightMode"= "ForwardAdd"}
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCg.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v{
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, float4(v.vertex,1.0));
                o.uv = v.texcoord.xy *_MainTex_ST.xy + _MainTex_ST.zw;
                
                return o;
            }

            fixed4 frag(v2f i): SV_TARGET{
                float3 worldNormal = i.worldNormal;

                #ifdef USING_DIRECTIONAL_LIGHT
                    float3 light=normalize(_WorldSpaceLightPos0);
                #else
                    float3 light=normalize(_WorldSpaceLightPos0-i.worldPosition);
                #endif

                float3 view = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                float3 half_vec = normalize(view+light);
                
                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(light,worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(half_vec, worldNormal)),_Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT
                    float atten=1.0;
                #else
                    float3 lightSpacePosition = mul(unity_WorldToLight,float4(i.worldPosition,1.0)).xyz;
                    
                    float atten = tex2D(_LightTexture0,dot(lightSpacePosition,lightSpacePosition).rr).UNITY_ATTEN_CHANNEL;
                    
                #endif

                return fixed4(( diffuse + specular)*atten, 1.0);
            } 
            ENDCG
        }
    }
    Fallback "Specular"
}
