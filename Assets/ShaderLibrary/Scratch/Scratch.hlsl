#include "Input/Transformation.hlsl"
#include "CoreRP/ShaderLibrary/Common.hlsl"

float3 ShadeDirectionalLight(float3 normalWS, float3 albedo, float3 lightDirectionWS, float3 lightColor)
{
    float attenuation = 5.0;
    float n_dot_l = max(dot(normalWS, lightDirectionWS), 0.0);
    return albedo * lightColor * n_dot_l * attenuation;
}

float3 ShadePointLight(float3 normalWS, float3 albedo, float3 fragmentPositionWS, float3 lightPositionWS, float range, float3 color)
{
    float3 lightVector = lightPositionWS - fragmentPositionWS;
    float3 lightDirectionWS = normalize(lightVector);
    float attenuation = range / dot(lightVector, lightVector);
    float n_dot_l = max(dot(normalWS, lightDirectionWS), 0.0);
    return albedo * color * n_dot_l * attenuation;
}

float3 SampleDepthAsWorldPosition(TEXTURE2D_FLOAT(CameraDepthTexture), SAMPLER(sampler_CameraDepthTexture), float2 uv)
{
    float2 positionNDC = uv;
#if UNITY_UV_STARTS_AT_TOP
    positionNDC.y = 1 - positionNDC.y;
#endif

    float deviceDepth = SAMPLE_DEPTH_TEXTURE(CameraDepthTexture, sampler_CameraDepthTexture, uv).r;
#if UNITY_REVERSED_Z
    deviceDepth = 1 - deviceDepth;
#endif
    deviceDepth = 2 * deviceDepth - 1;
    
    float3 positionVS = ComputeViewSpacePosition(positionNDC, deviceDepth, unity_CameraInvProjection);
    float3 positionWS = mul(unity_CameraToWorld, float4(positionVS, 1)).xyz;
    
    return positionWS;
}

//float3 DecodeNormal(float3 
