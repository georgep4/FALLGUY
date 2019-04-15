//////////////////////////////////////////////////////
// MK Glow Pre Sample								//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////

#ifndef MK_GLOW_PRE_SAMPLE
	#define MK_GLOW_PRE_SAMPLE

	#include "../Inc/Common.hlsl"
	
	UNIFORM_SAMPLER_AND_TEXTURE_2D(_SourceTex)
	#ifndef COMPUTE_SHADER
		uniform float2 _SourceTex_TexelSize;
		uniform half _LumaScale;
	#endif
	#ifdef MK_BLOOM
		#ifdef COMPUTE_SHADER
			UNIFORM_RWTEXTURE_2D(_BloomTargetTex)
		#else
			uniform half2 _BloomThreshold;
		#endif
	#endif

	#ifdef MK_COPY
		#ifdef COMPUTE_SHADER
			UNIFORM_RWTEXTURE_2D(_CopyTargetTex)
		#endif
	#endif

	#ifdef MK_LENS_FLARE
		static const float2 UV_HALF = half2(0.5, 0.5);

		UNIFORM_SAMPLER_AND_TEXTURE_2D(_LensFlareColorRamp)
		
		#ifdef COMPUTE_SHADER
			UNIFORM_RWTEXTURE_2D(_LensFlareTargetTex)
		#else
			uniform half2 _LensFlareThreshold;
			uniform half4 _LensFlareGhostParams; //count, dispersal, fade, _intensity
			uniform half3 _LensFlareHaloParams; //size, fade, _intensity
		#endif
	#endif

	#ifdef MK_GLARE
		#ifdef COMPUTE_SHADER
			UNIFORM_RWTEXTURE_2D(_Glare0TargetTex)
		#else
			uniform half2 _GlareThreshold;
		#endif
	#endif
		
	#ifdef COMPUTE_SHADER
		#define HEADER [numthreads(8,8,1)] void PreSample (uint2 id : SV_DispatchThreadID)
	#else
		#define HEADER FragmentOutputAuto frag (VertGeoOutputSimple o)
	#endif
	
	#ifdef MK_LENS_FLARE
		inline float CreateHalo(float2 uv, float2 offset, float2 size, half intensity, half fade)
		{
			return pow(1.0 - length(UV_HALF - frac(uv + offset + size)) / length(UV_HALF), fade) * intensity;
		}
	#endif

	#ifdef UNITY_SINGLE_PASS_STEREO
		#define STEREO_OFFSET float2(0.1875,0)
	#endif

	HEADER
	{
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
		#ifndef COMPUTE_SHADER
			FragmentOutputAuto fO;
			UNITY_INITIALIZE_OUTPUT(FragmentOutputAuto, fO);
		#endif
		
		#ifdef MK_BLOOM
			#ifdef TARGET_LQ
				BLOOM_RENDER_TARGET = SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), BLOOM_UV);
			#else
				BLOOM_RENDER_TARGET = DownsampleHQ(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), BLOOM_UV, SOURCE_TEXEL_SIZE);
			#endif
			BLOOM_RENDER_TARGET = half4(LuminanceThreshold(BLOOM_RENDER_TARGET.rgb, BLOOM_THRESHOLD, LUMA_SCALE), 1);
		#endif

		#ifdef MK_COPY
			#ifdef COMPUTE_SHADER
				COPY_RENDER_TARGET = _SourceTex[id];
			#else
				COPY_RENDER_TARGET = SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), UV_COPY);
			#endif
		#endif

		#ifdef MK_LENS_FLARE
			LENS_FLARE_RENDER_TARGET = half4(0,0,0,1);

			#if SHADER_TARGET >= 35
				[unroll(5)]
				for (int i = 0; i < LENS_FLARE_GHOST_COUNT; ++i)
			#else //shader model 3 has some issues with dynamic loop lengts, [loop] seems also not to be an option on some hardware
				for (int i = 0; i < 3; ++i)
			#endif
			{ 
				float2 offset = frac(LENS_FLARE_UV + (UV_HALF - LENS_FLARE_UV) * LENS_FLARE_GHOST_DISPERSAL * i);

				half weight = pow(1.0 - length(UV_HALF - offset) / length(UV_HALF), LENS_FLARE_GHOST_FADE);

				LENS_FLARE_RENDER_TARGET += half4(LuminanceThreshold(SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), offset).rgb, LENS_FLARE_THRESHOLD, LUMA_SCALE).rgb * weight, 0) * LENS_FLARE_GHOST_INTENSITY;
			}
			
			half2 haloSize;
			float weight;
			#ifdef UNITY_SINGLE_PASS_STEREO
				haloSize = normalize(UV_HALF - LENS_FLARE_UV) * LENS_FLARE_HALO_SIZE * 0.5;
				float4 haloSizeSP = float4(normalize(UV_HALF - LENS_FLARE_UV - STEREO_OFFSET),normalize(UV_HALF - LENS_FLARE_UV + STEREO_OFFSET)) * LENS_FLARE_HALO_SIZE;
				weight = CreateHalo(LENS_FLARE_UV, STEREO_OFFSET, haloSizeSP.xy * 0.5, LENS_FLARE_HALO_INTENSITY * 0.5, LENS_FLARE_HALO_FADE * 2.0);
				weight += CreateHalo(LENS_FLARE_UV, -STEREO_OFFSET, haloSizeSP.zw * 0.5, LENS_FLARE_HALO_INTENSITY * 0.5, LENS_FLARE_HALO_FADE * 2.0);
			#else
				haloSize = normalize(UV_HALF - LENS_FLARE_UV) * LENS_FLARE_HALO_SIZE;
				half2 haloSizeSP = normalize(UV_HALF - LENS_FLARE_UV) * LENS_FLARE_HALO_SIZE;
				weight = CreateHalo(LENS_FLARE_UV, 0, haloSizeSP, LENS_FLARE_HALO_INTENSITY, LENS_FLARE_HALO_FADE);
			#endif

			LENS_FLARE_RENDER_TARGET += half4(LuminanceThreshold(SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), LENS_FLARE_UV + haloSize).rgb * weight, LENS_FLARE_THRESHOLD, LUMA_SCALE), 0);
			#ifdef UNITY_SINGLE_PASS_STEREO
				LENS_FLARE_RENDER_TARGET *= SampleTex2D(PASS_TEXTURE_2D(_LensFlareColorRamp, sampler_LensFlareColorRamp), abs(length(UV_HALF - LENS_FLARE_UV - STEREO_OFFSET)) / length(UV_HALF));
			#else
				LENS_FLARE_RENDER_TARGET *= SampleTex2D(PASS_TEXTURE_2D(_LensFlareColorRamp, sampler_LensFlareColorRamp), abs(length(UV_HALF - LENS_FLARE_UV)) / length(UV_HALF));
			#endif
		#endif

		#ifdef MK_GLARE
			GLARE0_RENDER_TARGET = DownsampleLQ(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), GLARE_UV, SOURCE_TEXEL_SIZE);
			GLARE0_RENDER_TARGET = half4(LuminanceThreshold(GLARE0_RENDER_TARGET.rgb, GLARE_THRESHOLD, LUMA_SCALE), 1);
		#endif

		#ifndef COMPUTE_SHADER
			return fO;
		#endif
	}
#endif