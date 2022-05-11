Shader "Chapter 14/Hatching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color Tint", Color) = (1.0,1.0,1.0,1.0)
        _OutlineSize("OutlineSize",Range(0,1)) = 0.5
        _OutlineColor("OutlineColor", Color) = (0.0, 0.0, 0.0, 1.0)
        _HatchingTiling("_HatchingTiling", float) = 1.0
        _HatchingTex0("_HatchingTex0", 2D) = "white"{}
        _HatchingTex1("_HatchingTex1", 2D) = "white"{}
        _HatchingTex2("_HatchingTex2", 2D) = "white"{}
        _HatchingTex3("_HatchingTex3", 2D) = "white"{}
        _HatchingTex4("_HatchingTex4", 2D) = "white"{}
        _HatchingTex5("_HatchingTex5", 2D) = "white"{}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        UsePass "Chapter 14/ToonStyle/OUTLINE"
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma target 5.0 

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1)
                float4 pos : SV_POSITION;
                float weights[6] : TEXCOORD2;
                float4 worldPos : TEXCOORD8;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float _HatchingTiling;
            sampler2D _HatchingTex0;
            sampler2D _HatchingTex1;
            sampler2D _HatchingTex2;
            sampler2D _HatchingTex3;
            sampler2D _HatchingTex4;
            sampler2D _HatchingTex5;

            v2f vert (appdata_base v)
            {
                v2f o;
                float3 normal = normalize(UnityObjectToWorldNormal(v.normal));
                float3 light = normalize(WorldSpaceLightDir(v.vertex));
                float black = 1 - saturate(dot(normal, light));
                float idxf = floor(black * 6);
                int idx = int(idxf);

                for(int i = 0; i<6;i++){
                    o.weights[i] = 0;
                }

                if(idx == 0){
                    
                }
                else if(idx==1){
                    o.weights[0] = idxf;
                    o.weights[1] = 1-o.weights[0];
                }
                else if(idx==2){
                    o.weights[1] = idxf - 1;
                    o.weights[2] = 1-o.weights[1];
                }
                else if(idx==3){
                    o.weights[2] = idxf - 2;
                    o.weights[3] = 1-o.weights[2];
                }
                else if(idx==4){
                    o.weights[3] = idxf - 3;
                    o.weights[4] = 1-o.weights[3];
                }
                else if(idx==5){
                    o.weights[4] = idxf - 4;
                    o.weights[5] = 1-o.weights[4];
                }
                else if(idx==6){
                    o.weights[5] = 1;
                }

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.texcoord * _HatchingTiling;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 hatching0 = tex2D(_HatchingTex0, i.uv).rgb * i.weights[0];
                fixed3 hatching1 = tex2D(_HatchingTex1, i.uv).rgb * i.weights[1];
                fixed3 hatching2 = tex2D(_HatchingTex2, i.uv).rgb * i.weights[2];
                fixed3 hatching3 = tex2D(_HatchingTex3, i.uv).rgb * i.weights[3];
                fixed3 hatching4 = tex2D(_HatchingTex4, i.uv).rgb * i.weights[4];
                fixed3 hatching5 = tex2D(_HatchingTex5, i.uv).rgb * i.weights[5];
                fixed3 whiteColor = fixed3(1,1,1) * (1 - i.weights[0] - i.weights[1] - i.weights[2] - i.weights[3] - i.weights[4] - i.weights[5]);

                fixed3 finalColor = hatching0 + hatching1 + hatching2 + hatching3 + hatching4 + hatching5 + whiteColor;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                return fixed4(finalColor * _Color * atten,1.0);
            }
            ENDCG
        }
    }
}
