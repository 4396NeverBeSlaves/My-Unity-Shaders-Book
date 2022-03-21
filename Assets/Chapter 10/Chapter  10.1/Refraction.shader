Shader "Chapter 10/Refraction"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RefractionColor("RefractionColor",Color)=(1.0,1.0,1.0,1.0)
        _RefractionAmount("RefractionAmount", Float)=1.0
        _ReflectionRatio("ReflectionRatio", Float)=1.0
        _Cubemap("Cubemap",Cube)="_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldRefactDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _RefractionColor;
            fixed _RefractionAmount;
            fixed _ReflectionRatio;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 view = WorldSpaceViewDir(v.vertex);
                o.worldRefactDir = refract(normalize(-view),normalize(o.worldNormal),1/_ReflectionRatio);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 normal = normalize(i.worldNormal);
                fixed3 view = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 light = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                fixed3 diffuse = albedo * saturate(dot(normal,light));
                fixed3 specular = texCUBE(_Cubemap, i.worldRefactDir).rgb *_RefractionColor;

                return fixed4(ambient+ lerp(diffuse, specular,_RefractionAmount),1.0);
            }
            ENDCG
        }
    }
}
