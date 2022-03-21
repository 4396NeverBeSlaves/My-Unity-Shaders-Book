Shader "Unlit/AlphaBlendBothSide"
{
Properties{
        _MainTex("Albedo", 2D)="white"{}
        _Color("Color", Color)=(1.0,1.0,1.0,1.0)
        _Specular("Specular", Color)=(1.0,1.0,1.0,1.0)
        _Gloss("Gloss", Float)= 20
        _AlphaScale("_AlphaScale", Float)=0.5
    }

    SubShader{
        Tags{"Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True"}

        pass{
            Tags{"LightMode"= "ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCg.cginc"
            #include "Lighting.cginc"

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
            fixed _AlphaScale;

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
                float3 light = normalize(_WorldSpaceLightPos0);
                float3 view = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                float3 half_vec = normalize(view+light);
                
                fixed4 albedo = tex2D(_MainTex,i.uv) * _Color;
                fixed3 ambient= albedo.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(light,worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(half_vec, worldNormal)),_Gloss);

                return fixed4(ambient + diffuse + specular, albedo.a*_AlphaScale);
            } 

            ENDCG
        }

        pass{
            Tags{"LightMode"= "ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCg.cginc"
            #include "Lighting.cginc"

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
            fixed _AlphaScale;

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
                float3 light = normalize(_WorldSpaceLightPos0);
                float3 view = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                float3 half_vec = normalize(view+light);
                
                fixed4 albedo = tex2D(_MainTex,i.uv) * _Color;
                fixed3 ambient= albedo.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(light,worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(half_vec, worldNormal)),_Gloss);

                return fixed4(ambient + diffuse + specular, albedo.a*_AlphaScale);
            } 

            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
