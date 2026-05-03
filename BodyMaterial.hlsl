void bodyMaterial_float(
    UnityTexture2D Wetness_Mask,
    UnityTexture2D Albedo_Tex,
    UnityTexture2D Normal_Tex,
    UnityTexture2D AO_Tex,
    float2 UV0,
    float2 UV1,

    out float3 Albedo,
    out float3 Normal,
    out float Smoothness,
    out float AO,
    out float3 Specular
)
{    
    float wet = SAMPLE_TEXTURE2D(Wetness_Mask.tex, Wetness_Mask.samplerstate, UV0).r;
    float3 albedo = SAMPLE_TEXTURE2D(Albedo_Tex.tex, Albedo_Tex.samplerstate, UV1).rgb;
    float3 normal = SAMPLE_TEXTURE2D(Normal_Tex.tex, Normal_Tex.samplerstate, UV1).rgb;
    float ao = SAMPLE_TEXTURE2D(AO_Tex.tex, AO_Tex.samplerstate, UV1).r;
   
    float3 normalUnpack = normal.xyz * 2.0 - 1.0;
    float normalStrength = 1.0;
    normalUnpack.xy *= normalStrength;

    Albedo = albedo; 
    Normal = normalize(normalUnpack);
    
    Smoothness = lerp(0.1, 0.8, wet);
    
    float3 drySpec = float3(0.02, 0.02, 0.02);
    float3 wetSpec = float3(0.055, 0.055, 0.055);
    Specular = lerp(drySpec, wetSpec, wet);
    
    AO = ao;
}
