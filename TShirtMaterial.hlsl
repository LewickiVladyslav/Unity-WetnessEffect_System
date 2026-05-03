void tShirtMaterial_float(
    UnityTexture2D Wetness_Mask,
    UnityTexture2D Albedo_Tex,
    UnityTexture2D Normal_Tex,
    float2 UV,
    float3 Wetness_Tint,
    out float3 Albedo,
    out float3 Normal,
    out float Smoothness,
    out float Alpha
)
{
    float wet = SAMPLE_TEXTURE2D(Wetness_Mask.tex, Wetness_Mask.samplerstate, UV).r;
    float3 albedo = SAMPLE_TEXTURE2D(Albedo_Tex.tex, Albedo_Tex.samplerstate, UV).rgb;
    float3 normal = SAMPLE_TEXTURE2D(Normal_Tex.tex, Normal_Tex.samplerstate, UV).rgb;
   
    float3 normalUnpack = normal.xyz * 2.0 - 1.0;
    float normalStrength = lerp(1, 1.66, wet);
    normalUnpack.xy *= normalStrength;
    
    Albedo = lerp(albedo,albedo * Wetness_Tint, wet);
    Normal = normalize(normalUnpack);
    Smoothness = lerp(0.1, 0.5, wet);
    Alpha = lerp(1.0, 0.9, wet);
}
