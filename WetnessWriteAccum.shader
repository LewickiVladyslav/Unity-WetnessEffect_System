Shader "Hidden/WetnessWriteAccum"
{
    Properties
    {
        NoiseTex ("Noise Texture", 2D) = "gray" {}
        NoiseScale ("Noise Scale", Float) = 4.0
        NoiseStrength ("Noise Strength", Float) = 0.05
        EdgeWidth ("Edge Width", Float) = 0.02
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Overlay" }

        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            Blend Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D PrevMask;
            sampler2D NoiseTex;

            float NoiseScale;
            float NoiseStrength;
            float EdgeWidth;

            float WaterLevel;
            float DryCoef;
            float DeltaTime;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float worldY : TEXCOORD1;
            };

            Varyings vert(Attributes v)
            {
                Varyings o;

                o.worldY = mul(unity_ObjectToWorld, v.positionOS).y;
                o.uv = v.uv;

                float2 uvClip = v.uv * 2.0 - 1.0;
                o.positionCS = float4(uvClip.x, -uvClip.y, 0.0, 1.0);

                return o;
            }

            fixed4 frag(Varyings i) : SV_Target
            {
                float prev = tex2D(PrevMask, i.uv).r;

                float noise = tex2D(NoiseTex, i.uv * NoiseScale).r;
                float noisyWaterLevel = WaterLevel + (noise * 2.0 - 1.0) * NoiseStrength;

                float curr = 1.0 - smoothstep(noisyWaterLevel - EdgeWidth, noisyWaterLevel + EdgeWidth, i.worldY);

                float dryPrev = prev * exp(-DryCoef * DeltaTime);
                float result = saturate(max(curr, dryPrev));

                return fixed4(result, 0.0, 0.0, 1.0);
            }
            ENDHLSL
        }
    }
}