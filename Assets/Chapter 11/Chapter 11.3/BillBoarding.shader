Shader "Chapter 11/BillBoarding"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1.0, 1.0,1.0,1.0)
        _FollowView("_FollowView",Range(0,1)) = 1 
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"= "Transparent" "IgnoreProjector"="True"  "DisableBatching"="True"}
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
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
            float _FollowView;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;

                float3 center = (0);
                float3 normal = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1.0)).xyz-center;

                normal.y *=_FollowView;
                normal = normalize(normal);

                float3 upDir = abs(normal.y)> 0.99? float3(0,0,1):float3(0,1,0);
                float3 rightDir = normalize(cross(upDir,normal));
                upDir = normalize(cross(normal, rightDir));
                float3x3 transMat = float3x3( rightDir,upDir ,normal);
                
                float3 centerOffset = v.vertex.xyz-center;
                float3 newPos = mul( centerOffset,transMat) + center;


                o.vertex = UnityObjectToClipPos(float4(newPos,1.0));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
