//////////////////////////////////////////////////////
// MK Glow Common									//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////

//////////////////////////////////////////////////////
// Keyword replacement matrix                       //
// These keywords are already build-in so we can use//
// some slots to avoid reaching keyword limit (256) //
//////////////////////////////////////////////////////
// _MK_BLOOM             | _NORMALMAP
// _MK_LENS_SURFACE      | _ALPHATEST_ON
// _MK_LENS_FLARE        | _ALPHABLEND_ON
// _MK_GLARE             | _ALPHAPREMULTIPLY_ON
// _DEBUG_RAW_BLOOM      | _EMISSION
// _DEBUG_RAW_LENS_FLARE | _METALLICGLOSSMAP
// _DEBUG_RAW_GLARE      | _DETAIL_MULX2
// _DEBUG_BLOOM          | _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
// _DEBUG_LENS_FLARE     | _SPECULARHIGHLIGHTS_OFF
// _DEBUG_GLARE          | _GLOSSYREFLECTIONS_OFF
// _MK_COPY              | _PARALLAXMAP
// _DEBUG_COMPOSITE      | EDITOR_VISUALIZATION

//////////////////////////////////////////////////////
// Supported features based on shader model         //
//////////////////////////////////////////////////////
// 2.0  | Bloom, Lens Surface
// 2.5  | Bloom, Lens Surface
// 3.0  | Bloom, Lens Surface, Lens Flare
// 3.5  | Bloom, Lens Surface, Lens Flare
// 4.0  | Bloom, Lens Surface, Lens Flare, Glare, Geometry Shaders
// 4.5+ | Bloom, Lens Surface, Lens Flare, Glare, Geometry Shaders, Direct Compute

///////////////////////////////////
// Direct Compute Feature Matrix //
///////////////////////////////////
//   2x4  |   3x8	  |   4x16
//0	 --		  ---		  ----
//1	 +-		  +--		  +---
//2	 -+		  -+-		  -+--
//3	 ++		  ++-		  ++--
//4			  --+		  --+-
//5			  +++		  +++-
//6			  -++		  -++-
//7			  +-+		  +-+-
//8						  -+-+
//9 			  		  ---+
//10			  		  --++
//11					  -+++
//12				 	  ++-+
//13					  ++++
//14					  +-++
//15					  +--+

///////////////////////////////
//		CBuffer Inputs		 //
///////////////////////////////
// Index | Buffer | Size
// 0 | _BloomThreshold | 2
// 2 | _LumaScale | 1
// 3 | _BloomSpread | 1
// 4 | _BloomIntensity | 1
// 5 | _Blooming  | 1
// 6 | _LensSurfaceDirtIntensity | 1
// 7 | _LensSurfaceDiffractionIntensity | 1
// 8 | _LensFlareThreshold | 2
// 10 | _LensFlareGhostParams | 4
// 14 | _LensFlareHaloParams | 3
// 17 | _LensFlareSpread | 1
// 18 | _LensFlareChromaticAberration | 1
// 19 | _GlareThreshold | 2
// 21 | _GlareScattering | 4
// 25 | _GlareDirection01 | 4
// 29 | _GlareDirection23 | 4
// 33 | _GlareBlend | 1
// 34 | _GlareIntensity | 4
// 38 | _ResolutionScale | 2
// 40 | _GlareOffset | 4
// 44 | _LensSurfaceDirtTex_ST | 4

#ifndef MK_GLOW_COMMON
	#define MK_GLOW_COMMON

	#include "UnityCG.cginc"
	
	#ifdef _COMPUTE_SHADER
		#define COMPUTE_SHADER
	#else
		#ifdef UNITY_COLORSPACE_GAMMA
			#define COLORSPACE_GAMMA
		#endif
		#ifdef _GEOMETRY_SHADER
			#define GEOMETRY_SHADER
		#endif
	#endif

	#if defined(SHADER_API_GLES3) || defined(SHADER_API_GLES) || defined(_TARGET_MOBILE) || defined(_TARGET_LQ)
		#define TARGET_LQ
	#endif

	#ifdef COMPUTE_SHADER
		uniform StructuredBuffer<float> _CArgBuffer;
	#endif

	/////////////////////////////////////////////////////////////////////////////////////////////
	// Shader Model dependent Macros
	/////////////////////////////////////////////////////////////////////////////////////////////
	#if defined(COMPUTE_SHADER) || SHADER_TARGET >= 35
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define UNIFORM_TEXTURE_2D(textureName) uniform Texture2DArray<half4> textureName;
			#define UNIFORM_SAMPLER_AND_TEXTURE_2D(textureName) uniform Texture2DArray<half4> textureName; uniform SamplerState sampler##textureName;
			#define DECLARE_TEXTURE_2D_ARGS(textureName, samplerName) Texture2DArray<half4> textureName, SamplerState samplerName
		#else
			#define UNIFORM_TEXTURE_2D(textureName) uniform Texture2D<half4> textureName;
			#define UNIFORM_SAMPLER_AND_TEXTURE_2D(textureName) uniform Texture2D<half4> textureName; uniform SamplerState sampler##textureName;
			#define DECLARE_TEXTURE_2D_ARGS(textureName, samplerName) Texture2D<half4> textureName, SamplerState samplerName
		#endif

		#define UNIFORM_TEXTURE_2D_NO_SCALE(textureName) uniform Texture2D<half4> textureName;
		#define UNIFORM_SAMPLER_AND_TEXTURE_2D_NO_SCALE(textureName) uniform Texture2D<half4> textureName; uniform SamplerState sampler##textureName;
		#define DECLARE_TEXTURE_2D_NO_SCALE_ARGS(textureName, samplerName) Texture2D<half4> textureName, SamplerState samplerName

		#define PASS_TEXTURE_2D(textureName, samplerName) textureName, samplerName
	#else
		#define UNIFORM_TEXTURE_2D(textureName) uniform sampler2D textureName;
		#define UNIFORM_SAMPLER_AND_TEXTURE_2D(textureName) uniform sampler2D textureName;
		#define DECLARE_TEXTURE_2D_ARGS(textureName, samplerName) sampler2D textureName

		#define UNIFORM_TEXTURE_2D_NO_SCALE(textureName) UNIFORM_TEXTURE_2D(textureName)
		#define UNIFORM_SAMPLER_AND_TEXTURE_2D_NO_SCALE(textureName) UNIFORM_SAMPLER_AND_TEXTURE_2D(textureName)
		#define DECLARE_TEXTURE_2D_NO_SCALE_ARGS(textureName, samplerName) DECLARE_TEXTURE_2D_ARGS(textureName, samplerName)

		#define PASS_TEXTURE_2D(textureName, samplerName) textureName
	#endif


	#ifdef COMPUTE_SHADER
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define UNIFORM_RWTEXTURE_2D(textureName) uniform RWTexture2DArray<half4> textureName; uniform SamplerState sampler##textureName;
		#else
			#define UNIFORM_RWTEXTURE_2D(textureName) uniform RWTexture2D<half4> textureName; uniform SamplerState sampler##textureName;
		#endif
	#endif

	#if UNITY_SINGLE_PASS_STEREO
		static const float4 _DEFAULT_SCALE_TRANSFORM = float4(0.5,1,0,0);
	#else
		static const float4 _DEFAULT_SCALE_TRANSFORM = float4(1,1,0,0);
	#endif

	/////////////////////////////////////////////////////////////////////////////////////////////
	// Cross compile macros direct compute & shader
	/////////////////////////////////////////////////////////////////////////////////////////////
	#ifdef COMPUTE_SHADER
		//Other
		#define SOURCE_TEXEL_SIZE AutoScaleTexelSize(ComputeTexelSize(_SourceTex))
		#define COPY_RENDER_TARGET _CopyTargetTex[id]
		#define RETURN_TARGET_TEX _TargetTex[id] =
		#define SAMPLE_SOURCE _SourceTex[id]
		#define RESOLUTION_SCALE ComputeFloat2FromBuffer(_CArgBuffer, 38)
		#define UV_0 ComputeTexcoord(id, AutoScaleTexelSize(ComputeTexelSize(_TargetTex)))
		#define LUMA_SCALE ComputeFloatFromBuffer(_CArgBuffer, 2)

		//Bloom
		#define BLOOM_UV ComputeTexcoord(id, AutoScaleTexelSize(ComputeTexelSize(_BloomTargetTex)))
		#define BLOOM_RENDER_TARGET _BloomTargetTex[id]
		#define BLOOM_THRESHOLD ComputeFloat2FromBuffer(_CArgBuffer, 0)
		#define BLOOM_TEXEL_SIZE AutoScaleTexelSize(ComputeTexelSize(_BloomTex))
		#define BLOOM_UPSAMPLE_SPREAD AutoScaleTexelSize(ComputeTexelSize(_BloomTex)) * ComputeFloatFromBuffer(_CArgBuffer, 3)
		#define BLOOM_COMPOSITE_SPREAD AutoScaleTexelSize(ComputeTexelSize(_BloomTex)) * ComputeFloatFromBuffer(_CArgBuffer, 3)
		#define BLOOM_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 4)
		#define BLOOMING ComputeFloatFromBuffer(_CArgBuffer, 5)

		//Lens Surface
		#define LENS_SURFACE_DIRT_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 6)
		#define LENS_SURFACE_DIFFRACTION_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 7)
		#define LENS_SURFACE_DIRT_UV UV_0 * ComputeFloat2FromBuffer(_CArgBuffer, 44) + ComputeFloat2FromBuffer(_CArgBuffer, 46)
		#define LENS_DIFFRACTION_UV LensSurfaceDiffractionUV(UV_0)
		
		//Lens Flare
		#define LENS_FLARE_UV ComputeTexcoord(id, AutoScaleTexelSize(ComputeTexelSize(_LensFlareTargetTex)))
		#define LENS_FLARE_RENDER_TARGET _LensFlareTargetTex[id]
		#define LENS_FLARE_THRESHOLD ComputeFloat2FromBuffer(_CArgBuffer, 8)
		#define LENS_FLARE_GHOST_COUNT ComputeFloatFromBuffer(_CArgBuffer, 10)
		#define LENS_FLARE_GHOST_DISPERSAL ComputeFloatFromBuffer(_CArgBuffer, 11)
		#define LENS_FLARE_GHOST_FADE ComputeFloatFromBuffer(_CArgBuffer, 12)
		#define LENS_FLARE_GHOST_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 13)
		#define LENS_FLARE_HALO_SIZE ComputeFloatFromBuffer(_CArgBuffer, 14)
		#define LENS_FLARE_HALO_FADE ComputeFloatFromBuffer(_CArgBuffer, 15)
		#define LENS_FLARE_HALO_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 16)
		#define LENS_FLARE_TEXEL_SIZE AutoScaleTexelSize(ComputeTexelSize(_LensFlareTex))
		#define LENS_FLARE_UPSAMPLE_SPREAD LENS_FLARE_TEXEL_SIZE * ComputeFloatFromBuffer(_CArgBuffer, 17)
		#define LENS_FLARE_CHROMATIC_ABERRATION AutoScaleTexelSize(ComputeTexelSize(_LensFlareTex)) * ComputeFloatFromBuffer(_CArgBuffer, 18) * RESOLUTION_SCALE

		//Glare
		#define GLARE_UV ComputeTexcoord(id, AutoScaleTexelSize(ComputeTexelSize(_Glare0TargetTex)))
		#define GLARE0_RENDER_TARGET _Glare0TargetTex[id]
		#define GLARE_THRESHOLD ComputeFloat2FromBuffer(_CArgBuffer, 19)
		#define GLARE0_DIFFUSION ComputeFloatFromBuffer(_CArgBuffer, 21)
		#define GLARE1_DIFFUSION ComputeFloatFromBuffer(_CArgBuffer, 22)
		#define GLARE2_DIFFUSION ComputeFloatFromBuffer(_CArgBuffer, 23)
		#define GLARE3_DIFFUSION ComputeFloatFromBuffer(_CArgBuffer, 24)
		#define GLARE0_DIRECTION ComputeFloat2FromBuffer(_CArgBuffer, 25)
		#define GLARE1_DIRECTION ComputeFloat2FromBuffer(_CArgBuffer, 27)
		#define GLARE2_DIRECTION ComputeFloat2FromBuffer(_CArgBuffer, 29)
		#define GLARE3_DIRECTION ComputeFloat2FromBuffer(_CArgBuffer, 31)
		#define GLARE0_OFFSET ComputeFloatFromBuffer(_CArgBuffer, 40)
		#define GLARE1_OFFSET ComputeFloatFromBuffer(_CArgBuffer, 41)
		#define GLARE2_OFFSET ComputeFloatFromBuffer(_CArgBuffer, 42)
		#define GLARE3_OFFSET ComputeFloatFromBuffer(_CArgBuffer, 43)
		#define GLARE0_RENDER_TARGET _Glare0TargetTex[id]
		#define GLARE1_RENDER_TARGET _Glare1TargetTex[id]
		#define GLARE2_RENDER_TARGET _Glare2TargetTex[id]
		#define GLARE3_RENDER_TARGET _Glare3TargetTex[id]
		#define GLARE0_TEXEL_SIZE AutoScaleTexelSize(ComputeTexelSize(_Glare0Tex))
		#define GLARE0_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 34)
		#define GLARE1_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 35)
		#define GLARE2_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 36)
		#define GLARE3_INTENSITY ComputeFloatFromBuffer(_CArgBuffer, 37)
		#define GLARE_BLEND ComputeFloatFromBuffer(_CArgBuffer, 33)
		#define GLARE0_TEX_TEXEL_SIZE AutoScaleTexelSize(ComputeTexelSize(_Glare0Tex))
	#else
		//Other
		#define UV_COPY o.uv0.xy
		#define SOURCE_TEXEL_SIZE AutoScaleTexelSize(_SourceTex_TexelSize)
		#define COPY_RENDER_TARGET fO.GET_COPY_RT
		#define SOURCE_UV o.uv0.xy
		#define RETURN_TARGET_TEX return
		#define SAMPLE_SOURCE SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), SOURCE_UV)
		#define RESOLUTION_SCALE _ResolutionScale
		#define UV_0 o.uv0.xy
		#define LUMA_SCALE _LumaScale
		
		//Bloom
		#define BLOOM_UV o.uv0.xy
		#define BLOOM_RENDER_TARGET fO.GET_BLOOM_RT
		#define BLOOM_THRESHOLD _BloomThreshold
		#define BLOOM_TEXEL_SIZE AutoScaleTexelSize(_BloomTex_TexelSize)
		#define BLOOM_UPSAMPLE_SPREAD o.BLOOM_SPREAD
		#define BLOOM_COMPOSITE_SPREAD o.uv0.zw
		#define BLOOM_INTENSITY _BloomIntensity
		#define BLOOMING _Blooming 

		//Lens Surface
		#define LENS_SURFACE_DIRT_INTENSITY _LensSurfaceDirtIntensity
		#define LENS_SURFACE_DIFFRACTION_INTENSITY _LensSurfaceDiffractionIntensity
		#define LENS_SURFACE_DIRT_UV o.uv0.xy * _LensSurfaceDirtTex_ST.xy + _LensSurfaceDirtTex_ST.zw
		#define LENS_DIFFRACTION_UV o.MK_LENS_SURFACE_DIFFRACTION_UV

		//Lens Flare
		#define LENS_FLARE_UV o.uv0.xy
		#define LENS_FLARE_RENDER_TARGET fO.GET_LENS_FLARE_RT
		#define LENS_FLARE_THRESHOLD _LensFlareThreshold
		#define LENS_FLARE_GHOST_COUNT _LensFlareGhostParams.x
		#define LENS_FLARE_GHOST_DISPERSAL _LensFlareGhostParams.y
		#define LENS_FLARE_GHOST_FADE _LensFlareGhostParams.z
		#define LENS_FLARE_GHOST_INTENSITY _LensFlareGhostParams.w
		#define LENS_FLARE_HALO_SIZE _LensFlareHaloParams.x
		#define LENS_FLARE_HALO_FADE _LensFlareHaloParams.y
		#define LENS_FLARE_HALO_INTENSITY _LensFlareHaloParams.z
		#define LENS_FLARE_TEXEL_SIZE AutoScaleTexelSize(_LensFlareTex_TexelSize)
		#define LENS_FLARE_UPSAMPLE_SPREAD o.LENS_FLARE_SPREAD
		#define LENS_FLARE_CHROMATIC_ABERRATION o.LENS_FLARE_SPREAD

		//Glare
		#define GLARE_UV o.uv0.xy
		#define GLARE0_RENDER_TARGET fO.GET_GLARE0_RT
		#define GLARE_THRESHOLD _GlareThreshold
		#define GLARE0_DIFFUSION _GlareScattering.x
		#define GLARE1_DIFFUSION _GlareScattering.y
		#define GLARE2_DIFFUSION _GlareScattering.z
		#define GLARE3_DIFFUSION _GlareScattering.w
		#define GLARE0_DIRECTION _GlareDirection01.xy
		#define GLARE1_DIRECTION _GlareDirection01.zw
		#define GLARE2_DIRECTION _GlareDirection23.xy
		#define GLARE3_DIRECTION _GlareDirection23.zw
		#define GLARE0_OFFSET _GlareOffset.x
		#define GLARE1_OFFSET _GlareOffset.y
		#define GLARE2_OFFSET _GlareOffset.z
		#define GLARE3_OFFSET _GlareOffset.w
		#define GLARE1_RENDER_TARGET fO.GET_GLARE1_RT
		#define GLARE2_RENDER_TARGET fO.GET_GLARE2_RT
		#define GLARE3_RENDER_TARGET fO.GET_GLARE3_RT
		#define GLARE0_TEXEL_SIZE AutoScaleTexelSize(_Glare0Tex_TexelSize)
		#define GLARE_BLEND _GlareBlend
		#define GLARE0_INTENSITY _GlareIntensity.x
		#define GLARE1_INTENSITY _GlareIntensity.y
		#define GLARE2_INTENSITY _GlareIntensity.z
		#define GLARE3_INTENSITY _GlareIntensity.w
		#define GLARE0_TEX_TEXEL_SIZE AutoScaleTexelSize(_Glare0Tex_TexelSize)
	#endif

	/////////////////////////////////////////////////////////////////////////////////////////////
	// Features
	/////////////////////////////////////////////////////////////////////////////////////////////
	//Bloom
	#ifdef _NORMALMAP
		#define MK_BLOOM 1
		#define BLOOM_RT 0
	#endif

	//Copy
	#ifdef _PARALLAXMAP
		#define MK_COPY 1
		#define COPY_RT MK_BLOOM
	#endif

	//Lens Surface
	#ifdef _ALPHATEST_ON
		#define MK_LENS_SURFACE 1
	#endif

	//Lens Flare
	#if defined(_ALPHABLEND_ON) && (SHADER_TARGET >= 30 || defined(COMPUTE_SHADER))
		#define MK_LENS_FLARE 1
		#define LENS_FLARE_RT MK_BLOOM + MK_COPY
	#endif

	//Glare
	#if defined(_ALPHAPREMULTIPLY_ON) && (SHADER_TARGET >= 35 || defined(COMPUTE_SHADER))
		#ifdef MK_GLOW_UPSAMPLE
			#define MK_GLARE 4
		#else
			#define MK_GLARE 1
		#endif
		#define GLARE_RT MK_BLOOM + MK_COPY + MK_LENS_FLARE
	#endif

	//Debug Raw Bloom
	#ifdef _EMISSION
		#define DEBUG_RAW_BLOOM
	#endif

	//Debug Raw LensFlare
	#ifdef _METALLICGLOSSMAP
		#define DEBUG_RAW_LENS_FLARE
	#endif

	//Debug Raw Glare
	#ifdef _DETAIL_MULX2
		#define DEBUG_RAW_GLARE
	#endif

	//Debug Bloom
	#ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
		#define DEBUG_BLOOM
	#endif

	//Debug LensFlare
	#ifdef _SPECULARHIGHLIGHTS_OFF
		#define DEBUG_LENS_FLARE
	#endif

	//Debug Glare
	#ifdef _GLOSSYREFLECTIONS_OFF
		#define DEBUG_GLARE
	#endif

	//Debug Composite
	#ifdef EDITOR_VISUALIZATION
		#define DEBUG_COMPOSITE
	#endif

	/////////////////////////////////////////////////////////////////////////////////////////////
	// Sampling
	/////////////////////////////////////////////////////////////////////////////////////////////
	static const half3 REL_LUMA = half3(0.2126h, 0.7152h, 0.0722h);
	#define PI 3.14159265
	#define EPSILON 1.0e-4

	#ifdef COMPUTE_SHADER
		inline float ComputeFloatFromBuffer(in StructuredBuffer<float> buffer, in int index)
		{
			return buffer[index];
		}
		inline float2 ComputeFloat2FromBuffer(in StructuredBuffer<float> buffer, in int index)
		{
			return float2(buffer[index], buffer[index + 1]);
		}
		inline float3 ComputeFloat3FromBuffer(in StructuredBuffer<float> buffer, in int index)
		{
			return float3(buffer[index], buffer[index + 1], buffer[index + 2]);
		}
		inline float4 ComputeFloat4FromBuffer(in StructuredBuffer<float> buffer, in int index)
		{
			return float4(buffer[index], buffer[index + 1], buffer[index + 2], buffer[index + 3]);
		}

		inline float2 ComputeTexelSize(Texture2D<half4> tex)
		{
			uint width, height;
			tex.GetDimensions(width, height);
			return float2(1.0 / width, 1.0 / height);
		}

		inline float2 ComputeTexelSize(RWTexture2D<half4> tex)
		{
			uint width, height;
			tex.GetDimensions(width, height);
			return float2(1.0 / width, 1.0 / height);
		}

		inline float2 ComputeTexcoord(uint2 id, float2 texelSize)
		{
			return texelSize * id + 0.5 * texelSize;
		}
	#endif

	inline half4 SampleTex2D(DECLARE_TEXTURE_2D_ARGS(tex, samplerTex), float2 uv)
	{
		#if defined(COMPUTE_SHADER) || SHADER_TARGET >= 35
			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
				return tex.SampleLevel(samplerTex, float3((uv).xy, (float)unity_StereoEyeIndex), 0);
			#else
				return tex.SampleLevel(samplerTex, UnityStereoScreenSpaceUVAdjust(uv, _DEFAULT_SCALE_TRANSFORM), 0);
			#endif
		#else
			return tex2D(tex, UnityStereoScreenSpaceUVAdjust(uv, _DEFAULT_SCALE_TRANSFORM));
		#endif
	}

	inline half4 SampleTex2DNoScale(DECLARE_TEXTURE_2D_NO_SCALE_ARGS(tex, samplerTex), float2 uv)
	{
		#if defined(COMPUTE_SHADER) || SHADER_TARGET >= 35
			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
				return tex.SampleLevel(samplerTex, float3(uv,0), 0);
			#else
				return tex.SampleLevel(samplerTex, uv, 0);
			#endif
		#else
			return tex2D(tex, uv);
		#endif
	}

	inline float2 AutoScaleTexelSize(float2 texelSize)
	{
		#ifdef UNITY_SINGLE_PASS_STEREO
			texelSize.x *= 2;
			return texelSize;
		#else
			return texelSize;
		#endif
	}

	inline half Gaussian(float x)
	{
		return 1.0f / (2.0 * sqrt(2.0 * PI)) * exp(-(pow(x, 2)) / (2.0f * pow(2.0, 2)));
	}

	inline half3 Blooming(half3 color, half blooming)
	{
		return lerp(color.rgb, 0.5*(color.rgb+sqrt(color.rgb)), blooming);
	}

	inline half4 ConvertToColorSpace(half4 color)
	{
		#ifdef COLORSPACE_GAMMA
			color.rgb = LinearToGammaSpace(color.rgb);
			return color;
		#else
			return color;
		#endif
	}

	inline half3 LuminanceThreshold(half3 c, half2 threshold, half lumaScale)
	{		
		//brightness is defined by the relative luminance combined with the brightest color part to make it nicer to deal with the shader for artists
		//based on unity builtin brightpass thresholding
		//if any color part exceeds a value of 10 (builtin HDR max) then clamp it as a normalized vector to keep the color balance
		c = clamp(c, 0, normalize(c) * threshold.y);
		c *= lerp(0.909, 1.0 / (1.0 + REL_LUMA), lumaScale);
		//half brightness = lerp(max(dot(c.r, REL_LUMA.r), max(dot(c.g, REL_LUMA.g), dot(c.b, REL_LUMA.b))), max(c.r, max(c.g, c.b)), REL_LUMA);
		//picking just the brightest color part isn´t physically correct at all, but gives nices artistic results
		half brightness = max(c.r, max(c.g, c.b));
		//forcing a hard threshold to only extract really bright parts
		half softPart = EPSILON;//threshold.x * 0.0 + EPSILON;
		return max(0, c * max(pow(clamp(brightness - threshold.x + softPart, 0, 2 * softPart), 2) / (4 * softPart + EPSILON), brightness - threshold.x) / max(brightness, EPSILON));
	}

	inline half4 GaussianBlur1D(DECLARE_TEXTURE_2D_ARGS(tex, samplerTex), float2 uv, float2 texelSize, float blurWidth, half2 direction, float offset)
	{
		half4 color = half4(0,0,0,1);
		float sum = 0;
		float w = 0;

		for(int i0 = 1; i0 <= 5; i0++)
		{
			w = Gaussian(i0);
			sum += w;
			color.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + blurWidth * direction * i0 * texelSize + blurWidth * direction * texelSize * offset) * w;

			w = Gaussian(-i0);
			sum += w;
			color.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - blurWidth * direction * i0 * texelSize + blurWidth * direction * texelSize * offset) * w;
		}

		w = Gaussian(0);
		sum += w;
		color.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv).rgb * w;

		color.rgb /= sum;

		return color;
	}

	static const half2 DOWNSAMPLE_LQ_WEIGHT = half2(0.125, 0.03125);
	static const float4 DOWNSAMPLE_LQ_DIRECTION0 = float4(0.9, -0.9, 0.45, -0.45);
	static const float3 DOWNSAMPLE_LQ_DIRECTION1 = float3(0.9, 0.45, 0);
	//0 X 1 X 2
	//X 3 X 4 X
	//5 X 6 X 7
	//X 8 X 9 X
	//0 X 1 X 2
	inline half4 DownsampleLQ(DECLARE_TEXTURE_2D_ARGS(tex, samplerTex), float2 uv, float2 texelSize)
	{
		half3 sample0 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.yy).rgb;
		half3 sample1 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - texelSize * DOWNSAMPLE_LQ_DIRECTION1.zx).rgb;
		half3 sample2 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.xy).rgb;
		half3 sample3 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.ww).rgb;
		half3 sample4 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.zw).rgb;
		half3 sample5 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - texelSize * DOWNSAMPLE_LQ_DIRECTION1.xz).rgb;
		half3 sample6 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv).rgb;
		half3 sample7 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION1.xz).rgb;
		half3 sample8 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.wz).rgb;
		half3 sample9 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.zz).rgb;
		half3 sample10 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.yx).rgb;
		half3 sample11 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION1.zx).rgb;
		half3 sample12 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_LQ_DIRECTION0.xx).rgb;

		half4 o = half4((sample3 + sample4 + sample8 + sample9) * DOWNSAMPLE_LQ_WEIGHT.x, 1);
		o.rgb += (sample0 + sample1 + sample6 + sample5).rgb * DOWNSAMPLE_LQ_WEIGHT.y;
		o.rgb += (sample1 + sample2 + sample7 + sample6).rgb * DOWNSAMPLE_LQ_WEIGHT.y;
		o.rgb += (sample5 + sample6 + sample11 + sample10).rgb * DOWNSAMPLE_LQ_WEIGHT.y;
		o.rgb += (sample6 + sample7 + sample12 + sample11).rgb * DOWNSAMPLE_LQ_WEIGHT.y;

		return o;
	}
	
	static const half3 DOWNSAMPLE_HQ_WEIGHT = half3(0.0833333, 0.0208333, 0.0092333);
	static const float4 DOWNSAMPLE_HQ_DIRECTION0 = float4(1.45, -1.45, 0.9, -0.9);
	static const float4 DOWNSAMPLE_HQ_DIRECTION1 = float4(1.45, -1.45, 0.45, -0.45);
	static const float2 DOWNSAMPLE_HQ_DIRECTION2 = float2(0.9, 0);
	// 0 X 1 X 2 X 3
	// X 4 X 5 X 6 X
	// 7 X 8 X 9 X 0
	// X 1 X 2 X 3 X
	// 4 X 5 X 6 X 7
	// X 8 X 9 X 0 X
	// 1 X 2 X 3 X 4
	inline half4 DownsampleHQ(DECLARE_TEXTURE_2D_ARGS(tex, samplerTex), float2 uv, float2 texelSize)
	{
		#ifndef TARGET_LQ
			half3 sample0 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.yx).rgb;
			half3 sample1 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.wx).rgb;
			half3 sample2 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.zx).rgb;
			half3 sample3 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.xx).rgb;

			half3 sample4 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.wz).rgb;
			half3 sample5 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION2.yx).rgb;
			half3 sample6 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.zz).rgb;

			half3 sample7 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.yz).rgb;
			half3 sample8 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.wz).rgb;
			half3 sample9 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.zz).rgb;
			half3 sample10 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.xz).rgb;

			half3 sample11 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - texelSize * DOWNSAMPLE_HQ_DIRECTION2.xy).rgb;
			half3 sample12 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv).rgb;
			half3 sample13 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION2.xy).rgb;

			half3 sample14 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.yw).rgb;
			half3 sample15 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.ww).rgb;
			half3 sample16 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.zw).rgb;
			half3 sample17 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.xw).rgb;

			half3 sample18 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.ww).rgb;
			half3 sample19 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - texelSize * DOWNSAMPLE_HQ_DIRECTION2.yx).rgb;
			half3 sample20 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.zw).rgb;

			half3 sample21 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.yy).rgb;
			half3 sample22 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.wy).rgb;
			half3 sample23 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION1.zy).rgb;
			half3 sample24 = SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + texelSize * DOWNSAMPLE_HQ_DIRECTION0.xy).rgb;

			half4 color = half4((sample8 + sample9 + sample15 + sample16) * DOWNSAMPLE_HQ_WEIGHT.x, 1);

			color.rgb += (sample4 + sample5 + sample11 + sample12) * DOWNSAMPLE_HQ_WEIGHT.y;
			color.rgb += (sample5 + sample6 + sample12 + sample13) * DOWNSAMPLE_HQ_WEIGHT.y;
			color.rgb += (sample11 + sample12 + sample18 + sample19) * DOWNSAMPLE_HQ_WEIGHT.y;
			color.rgb += (sample12 + sample13 + sample19 + sample20) * DOWNSAMPLE_HQ_WEIGHT.y;

			color.rgb += (sample0 + sample1 + sample7 + sample8) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample1 + sample2 + sample8 + sample9) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample2 + sample3 + sample9 + sample10) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample7 + sample8 + sample14 + sample15) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample8 + sample9 + sample15 + sample16) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample9 + sample10 + sample16 + sample17) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample14 + sample15 + sample21 + sample22) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample15 + sample16 + sample22 + sample23) * DOWNSAMPLE_HQ_WEIGHT.z;
			color.rgb += (sample16 + sample17 + sample23 + sample24) * DOWNSAMPLE_HQ_WEIGHT.z;

			return color;
		#else
			return DownsampleLQ(PASS_TEXTURE_2D(tex, samplerTex), uv, texelSize);
		#endif
	}

	static const half3 UPSAMPLE_LQ_WEIGHT = half3(0.25, 0.125, 0.0625);
	static const float3 UPSAMPLE_LQ_DIRECTION = float3(1, -1, 0);
	//012
	//345
	//678
	inline half4 UpsampleLQ(DECLARE_TEXTURE_2D_ARGS(tex, samplerTex), float2 uv, float2 texelSize)
	{
		half4 s = half4(0,0,0,1);
		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv).rgb * UPSAMPLE_LQ_WEIGHT.x;

		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - UPSAMPLE_LQ_DIRECTION.zx * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.y;
		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - UPSAMPLE_LQ_DIRECTION.xz * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.y;
		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_LQ_DIRECTION.xz * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.y;
		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_LQ_DIRECTION.zx * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.y;

		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - UPSAMPLE_LQ_DIRECTION.xx * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.z;
		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_LQ_DIRECTION.xy * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.z;
		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_LQ_DIRECTION.yx * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.z;
		s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_LQ_DIRECTION.xx * texelSize).rgb * UPSAMPLE_LQ_WEIGHT.z;

		return s;
	}

	static const half UPSAMPLE_HQ_WEIGHT[5] = {0.16, 0.08, 0.04, 0.02, 0.01};
	static const float4 UPSAMPLE_HQ_DIRECTION0 = float4(1, -1, 2, -2);
	static const float3 UPSAMPLE_HQ_DIRECTION1 = float3(2, -2, 0);
	static const float3 UPSAMPLE_HQ_DIRECTION2 = float3(1, -1, 0);
	//01234
	//56789
	//01234
	//56789
	//01234
	inline half4 UpsampleHQ(DECLARE_TEXTURE_2D_ARGS(tex, samplerTex), float2 uv, float2 texelSize)
	{
		#ifndef TARGET_LQ
			half4 s = half4(0,0,0,1);
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv).rgb * UPSAMPLE_HQ_WEIGHT[0];
			
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - UPSAMPLE_HQ_DIRECTION2.zx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[1];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - UPSAMPLE_HQ_DIRECTION2.xz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[1];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION2.xz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[1];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION2.zx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[1];

			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - UPSAMPLE_HQ_DIRECTION2.xx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION2.xy * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION2.yx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION2.xx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION1.zx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION1.xz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION1.zy * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION1.yz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[2];

			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.wx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.yz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.xz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.zx * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.zy * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.xw * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.yw * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.wy * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[3];

			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.wz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[4];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.zz * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[4];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.zw * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[4];
			s.rgb += SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + UPSAMPLE_HQ_DIRECTION0.ww * texelSize).rgb * UPSAMPLE_HQ_WEIGHT[4];
			
			return s;
		#else
			return UpsampleLQ(PASS_TEXTURE_2D(tex, samplerTex), uv, texelSize);
		#endif
	}

	inline half4 SampleTex2DCircularChromaticAberration(DECLARE_TEXTURE_2D_ARGS(tex, samplerTex), float2 uv, float2 offset)
	{
		float2 uvOffset = normalize(0.5 - uv) * offset;
		return half4(
				SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv - uvOffset).r,
				SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv).g,
				SampleTex2D(PASS_TEXTURE_2D(tex, samplerTex), uv + uvOffset).b,
				1);
	}

	#if defined(MK_LENS_SURFACE)
		static half3x3 LensSurfaceDiffractionScale0 = half3x3
		(
			//X and Y of scale matrix has to be doubled to get correct pivot
			2, 0, -1,
			0, 2, -1,
			0, 0,  1
		);

		static half3x3 LensSurfaceDiffractionScale1 = half3x3
		(
			0.5, 0, 0.5,
			0, 0.5, 0.5,
			0, 0, 1
		);

		inline float2 LensSurfaceDiffractionUV(float2 uv)
		{
			float rotationView = dot(float3(UNITY_MATRIX_V._m00, UNITY_MATRIX_V._m10, UNITY_MATRIX_V._m20), float3(0,0,0.5)) + dot(float3(UNITY_MATRIX_V._m01, UNITY_MATRIX_V._m11, UNITY_MATRIX_V._m21), float3(0,0.5,0));
			float3x3 rotation = float3x3(
				cos(rotationView), -sin(rotationView), 0,
				sin(rotationView), cos(rotationView),  0,
				0, 0, 1
			);

		rotation = mul(mul(LensSurfaceDiffractionScale1, rotation), LensSurfaceDiffractionScale0);
		return mul(rotation, float3(uv, 1.0)).xy;
		}
	#endif

	/////////////////////////////////////////////////////////////////////////////////////////////
	// Default Shader Includes
	/////////////////////////////////////////////////////////////////////////////////////////////
	#ifndef COMPUTE_SHADER
		const static float4 SCREEN_VERTICES[3] = 
		{
			float4(-1.0, -1.0, 0.0, 1.0),
			float4(3.0, -1.0, 0.0, 1.0),
			float4(-1.0, 3.0, 0.0, 1.0)
		};

		/////////////////////////////////////////////////////////////////////////////////////////////
		// Helpers
		/////////////////////////////////////////////////////////////////////////////////////////////
		inline float4 TransformMeshPos(float4 pos)
		{
			return float4(pos.xy, 0.0, 1.0);
		}

		inline float2 SetMeshUV(float2 vertex)
		{
			float2 uv = (vertex + 1.0) * 0.5;
			#ifdef UNITY_UV_STARTS_AT_TOP
				uv = uv * float2(1.0, -1.0) + float2(0.0, 1.0);
			#endif
			return uv;
		}

		/////////////////////////////////////////////////////////////////////////////////////////////
		// In / Out Structs
		/////////////////////////////////////////////////////////////////////////////////////////////
		struct VertexInputOnlyPosition
		{
			float4 vertex : POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		#ifdef GEOMETRY_SHADER
			struct VertexInputEmpty 
			{
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
		#endif

		struct VertGeoOutputSimple
		{
			float4 pos : SV_POSITION;
			float2 uv0 : TEXCOORD0;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct VertGeoOutputAdvanced
		{
			float4 pos : SV_POSITION;
			float4 uv0 : TEXCOORD0;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct VertGeoOutputPlus
		{
			float4 pos : SV_POSITION;
			float4 uv0 : TEXCOORD0;
			float2 uv1 : TEXCOORD1;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		struct VertGeoOutputDouble
		{
			float4 pos : SV_POSITION;
			float4 uv0 : TEXCOORD0;
			float4 uv1 : TEXCOORD1;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		/////////////////////////////////////////////////////////////////////////////////////////////
		// Vertex
		/////////////////////////////////////////////////////////////////////////////////////////////
		#ifdef GEOMETRY_SHADER
			VertexInputEmpty vertEmpty(VertexInputEmpty i0)
			{
				VertexInputEmpty o;
				UNITY_SETUP_INSTANCE_ID(i0);
				UNITY_TRANSFER_INSTANCE_ID(i0, o);
				UNITY_INITIALIZE_OUTPUT(VertexInputEmpty, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}
		#endif

		VertGeoOutputSimple vertSimple (VertexInputOnlyPosition i0)
		{
			VertGeoOutputSimple o;

			UNITY_SETUP_INSTANCE_ID(i0);
			UNITY_INITIALIZE_OUTPUT(VertGeoOutputSimple, o);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

			o.pos = TransformMeshPos(i0.vertex);
			o.uv0 = SetMeshUV(i0.vertex.xy);
			return o;
		}

		/////////////////////////////////////////////////////////////////////////////////////////////
		// Geometry
		/////////////////////////////////////////////////////////////////////////////////////////////
		#ifdef GEOMETRY_SHADER
			[maxvertexcount(3)]
			void geomSimple(point VertexInputEmpty i0[1], inout TriangleStream<VertGeoOutputSimple> tristream)
			{
				VertGeoOutputSimple o;
				UNITY_INITIALIZE_OUTPUT(VertGeoOutputSimple, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i0[0], o);

				o.pos = TransformMeshPos(SCREEN_VERTICES[0]);
				o.uv0 = SetMeshUV(o.pos.xy);
				tristream.Append(o);

				o.pos = TransformMeshPos(SCREEN_VERTICES[1]);
				o.uv0 = SetMeshUV(o.pos.xy);
				tristream.Append(o);

				o.pos = TransformMeshPos(SCREEN_VERTICES[2]);
				o.uv0 = SetMeshUV(o.pos.xy);
				tristream.Append(o);
			}
		#endif

		/////////////////////////////////////////////////////////////////////////////////////////////
		// Fragment Output
		/////////////////////////////////////////////////////////////////////////////////////////////
		#define COUNT_ENABLED_TARGETS MK_BLOOM + MK_COPY + MK_LENS_FLARE + MK_GLARE

		#define RENDER_TARGET(target) half4 rt##target : SV_Target##target;
		#define GET_RT(index) rt##index

		#if BLOOM_RT == 0
			#define GET_BLOOM_RT GET_RT(0)
		#endif

		#if COPY_RT == 0
			#define GET_COPY_RT GET_RT(0)
		#elif COPY_RT == 1
			#define GET_COPY_RT GET_RT(1)
		#endif

		#if LENS_FLARE_RT == 0
			#define GET_LENS_FLARE_RT GET_RT(0)
		#elif LENS_FLARE_RT == 1
			#define GET_LENS_FLARE_RT GET_RT(1)
		#elif LENS_FLARE_RT == 2
			#define GET_LENS_FLARE_RT GET_RT(2)
		#endif

		#if GLARE_RT == 0
			#define GET_GLARE0_RT GET_RT(0)
			#ifdef MK_GLOW_UPSAMPLE
				#define GET_GLARE1_RT GET_RT(1)
				#define GET_GLARE2_RT GET_RT(2)
				#define GET_GLARE3_RT GET_RT(3)
			#endif
		#elif GLARE_RT == 1
			#define GET_GLARE0_RT rt1
			#ifdef MK_GLOW_UPSAMPLE
				#define GET_GLARE1_RT GET_RT(2)
				#define GET_GLARE2_RT GET_RT(3)
				#define GET_GLARE3_RT GET_RT(4)
			#endif
		#elif GLARE_RT == 2
			#define GET_GLARE0_RT GET_RT(2)
			#ifdef MK_GLOW_UPSAMPLE
				#define GET_GLARE1_RT GET_RT(3)
				#define GET_GLARE2_RT GET_RT(4)
				#define GET_GLARE3_RT GET_RT(5)
			#endif
		#elif GLARE_RT == 3
			#define GET_GLARE0_RT GET_RT(3)
			#ifdef MK_GLOW_UPSAMPLE
				#define GET_GLARE1_RT GET_RT(4)
				#define GET_GLARE2_RT GET_RT(5)
				#define GET_GLARE3_RT GET_RT(6)
			#endif
		#endif
		
		struct FragmentOutputAuto
		{	
			#if COUNT_ENABLED_TARGETS == 2
				RENDER_TARGET(0)
				RENDER_TARGET(1)
			#elif COUNT_ENABLED_TARGETS == 3
				RENDER_TARGET(0)
				RENDER_TARGET(1)
				RENDER_TARGET(2)
			#elif COUNT_ENABLED_TARGETS == 4
				RENDER_TARGET(0)
				RENDER_TARGET(1)
				RENDER_TARGET(2)
				RENDER_TARGET(3)
			#elif COUNT_ENABLED_TARGETS == 5
				RENDER_TARGET(0)
				RENDER_TARGET(1)
				RENDER_TARGET(2)
				RENDER_TARGET(3)
				RENDER_TARGET(4)
			#elif COUNT_ENABLED_TARGETS == 6
				RENDER_TARGET(0)
				RENDER_TARGET(1)
				RENDER_TARGET(2)
				RENDER_TARGET(3)
				RENDER_TARGET(4)
				RENDER_TARGET(5)
			#else
				RENDER_TARGET(0)
			#endif
		};
	#endif
#endif