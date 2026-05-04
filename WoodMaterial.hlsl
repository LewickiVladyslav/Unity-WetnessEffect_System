void woodMaterial_float(
    UnityTexture2D Wetness_Mask,
    UnityTexture2D Albedo_Tex,
    UnityTexture2D Normal_Tex,
    UnityTexture2D AOS_Tex,
    float2 UV,
    out float3 Albedo,
    out float3 Normal,
    out float Smoothness,
    out float AO,
    out float3 Specular
)
{
    float wet = SAMPLE_TEXTURE2D(Wetness_Mask.tex, Wetness_Mask.samplerstate, UV).r;
    float3 albedo = SAMPLE_TEXTURE2D(Albedo_Tex.tex, Albedo_Tex.samplerstate, UV).rgb;
    float3 normal = SAMPLE_TEXTURE2D(Normal_Tex.tex, Normal_Tex.samplerstate, UV).rgb;
    float aos = SAMPLE_TEXTURE2D(AOS_Tex.tex, AOS_Tex.samplerstate, UV).rb;

    
    float3 normalUnpack = normal.xyz * 2.0 - 1.0;
 
    float wetWithAO = saturate(wet * 1.5 - (1.0 - aos.r) * 0.5);

    float3 wetAlbedo = pow(albedo, 1.5) * 0.62;
    Albedo = lerp(albedo, wetAlbedo, wetWithAO);
    
    Smoothness = lerp(0.05, 0.70, wet);
    
    Normal = normalUnpack;
   
    Specular = lerp(aos.b, float3(0.055, 0.055, 0.055), wet);
    
    AO = aos.r;
}
