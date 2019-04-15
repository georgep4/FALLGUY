//////////////////////////////////////////////////////
// MK Glow Debug									//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////

#ifndef MK_GLOW_DEBUG
	#define MK_GLOW_DEBUG

	#include "../Inc/Common.hlsl"

	#ifdef COMPUTE_SHADER
		UNIFORM_RWTEXTURE_2D(_TargetTex)
	#endif
	#if defined(DEBUG_RAW_BLOOM)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_SourceTex)
		#ifndef COMPUTE_SHADER
			uniform half2 _BloomThreshold;
			uniform half _LumaScale;
		#endif
	#elif defined(DEBUG_RAW_LENS_FLARE)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_SourceTex)
		#ifndef COMPUTE_SHADER
			uniform half2 _LensFlareThreshold;
			uniform half _LumaScale;
		#endif
	#elif defined(DEBUG_RAW_GLARE)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_SourceTex)
		#ifndef COMPUTE_SHADER
			uniform half2 _GlareThreshold;
			uniform half _LumaScale;
		#endif
	#elif defined(DEBUG_LENS_FLARE)
		#ifndef COMPUTE_SHADER
			uniform float2 _ResolutionScale;
			uniform float _LensFlareChromaticAberration;
			uniform float2 _LensFlareTex_TexelSize;
		#endif
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_LensFlareTex)
	#elif defined(DEBUG_GLARE)
		#ifndef COMPUTE_SHADER
			uniform float2 _ResolutionScale;
			uniform float2 _Glare0Tex_TexelSize;

			uniform half _GlareBlend;
			uniform half4 _GlareIntensity; // 0 1 2 3
			uniform half4 _GlareScattering; // 0 1 2 3
			uniform half4 _GlareDirection01; // 0 1
			uniform half4 _GlareDirection23; // 2 3
			uniform float4 _GlareOffset; // 0 1 2 3
			uniform float _Blooming;
		#endif

		UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare0Tex)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare1Tex)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare2Tex)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare3Tex)
	#elif defined(DEBUG_COMPOSITE)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_SourceTex)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_BloomTex)
		#ifndef COMPUTE_SHADER
			uniform float2 _BloomTex_TexelSize;
			uniform half _BloomSpread;
			uniform half _BloomIntensity;
			uniform float _Blooming;
		#endif

		#ifdef MK_LENS_FLARE
			UNIFORM_SAMPLER_AND_TEXTURE_2D(_LensFlareTex)
			#ifndef COMPUTE_SHADER
				uniform float2 _LensFlareTex_TexelSize;
				uniform float _LensFlareChromaticAberration;
			#endif
		#endif

		#ifdef MK_LENS_SURFACE
			#ifndef COMPUTE_SHADER
				uniform half _LensSurfaceDirtIntensity;
				uniform half _LensSurfaceDiffractionIntensity;
				uniform float4 _LensSurfaceDirtTex_ST;
			#endif
			UNIFORM_SAMPLER_AND_TEXTURE_2D_NO_SCALE(_LensSurfaceDirtTex)
			UNIFORM_SAMPLER_AND_TEXTURE_2D_NO_SCALE(_LensSurfaceDiffractionTex)
		#endif

		#if defined(MK_LENS_FLARE) || defined(MK_GLARE)
			#ifndef COMPUTE_SHADER
				uniform float2 _ResolutionScale;
			#endif
		#endif

		#ifdef MK_GLARE
			#ifndef COMPUTE_SHADER
				uniform float2 _Glare0Tex_TexelSize;
				uniform half _GlareBlend;
				uniform half4 _GlareIntensity; // 0 1 2 3
				uniform half4 _GlareScattering; // 0 1 2 3
				uniform half4 _GlareDirection01; // 0 1
				uniform half4 _GlareDirection23; // 2 3
				uniform float4 _GlareOffset; // 0 1 2 3
			#endif
			UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare0Tex)
			UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare1Tex)
			UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare2Tex)
			UNIFORM_SAMPLER_AND_TEXTURE_2D(_Glare3Tex)
		#endif
	#else
		#ifndef COMPUTE_SHADER
			uniform float2 _BloomTex_TexelSize;
		#endif
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_BloomTex)
		uniform half _BloomSpread;
		uniform half _BloomIntensity;
		uniform float _Blooming;
	#endif

	#ifndef COMPUTE_SHADER
		#ifdef DEBUG_COMPOSITE
			#if defined(MK_LENS_SURFACE) && defined(MK_LENS_FLARE)
				#define VertGeoOutput VertGeoOutputDouble
				#define MK_LENS_SURFACE_DIFFRACTION_UV uv1.xy
				#define LENS_FLARE_SPREAD uv1.zw
			#elif defined(MK_LENS_SURFACE) || defined(MK_LENS_FLARE)
				#define VertGeoOutput VertGeoOutputPlus
				#define MK_LENS_SURFACE_DIFFRACTION_UV uv1.xy
				#define LENS_FLARE_SPREAD uv1.xy
			#else
				#define VertGeoOutput VertGeoOutputAdvanced
			#endif
		#else
			#if defined(MK_LENS_FLARE) || defined(DEBUG_LENS_FLARE)
				#define LENS_FLARE_SPREAD uv0.zw
				#define VertGeoOutput VertGeoOutputAdvanced
			#else
				#define VertGeoOutput VertGeoOutputAdvanced
			#endif
		#endif

		VertGeoOutput vert (VertexInputOnlyPosition i0)
		{
			VertGeoOutput o;
			UNITY_SETUP_INSTANCE_ID(i0);
			UNITY_INITIALIZE_OUTPUT(VertGeoOutput, o);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

			o.pos = TransformMeshPos(i0.vertex);

			o.uv0.xy = SetMeshUV(i0.vertex.xy);	

			#if defined(DEBUG_BLOOM) || defined(DEBUG_COMPOSITE)
				o.uv0.zw = BLOOM_TEXEL_SIZE * _BloomSpread;
			#endif

			#if defined(DEBUG_COMPOSITE) && defined(MK_LENS_SURFACE)
				o.MK_LENS_SURFACE_DIFFRACTION_UV = LensSurfaceDiffractionUV(o.uv0.xy);
			#endif
			#if defined(MK_LENS_FLARE) && defined(DEBUG_COMPOSITE) || defined(DEBUG_LENS_FLARE)
				o.LENS_FLARE_SPREAD = LENS_FLARE_TEXEL_SIZE * _LensFlareChromaticAberration * _ResolutionScale;
			#endif

			return o;
		}

		#ifdef GEOMETRY_SHADER
			[maxvertexcount(3)]
			void geom(point VertexInputEmpty i0[1], inout TriangleStream<VertGeoOutput> tristream)
			{
				VertGeoOutput o;
				UNITY_INITIALIZE_OUTPUT(VertGeoOutput, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i0[0], o);

				#if defined(DEBUG_BLOOM) || defined(DEBUG_COMPOSITE)
					float2 bloomSpread = BLOOM_TEXEL_SIZE * _BloomSpread;
				#endif
				#if defined(MK_LENS_FLARE) && defined(DEBUG_COMPOSITE) || defined(DEBUG_LENS_FLARE)
					float2 lensFlareSpread = LENS_FLARE_TEXEL_SIZE * _LensFlareChromaticAberration * _ResolutionScale;
				#endif

				o.pos = TransformMeshPos(SCREEN_VERTICES[0]);
				o.uv0.xy = SetMeshUV(o.pos.xy);
				#if defined(DEBUG_BLOOM) || defined(DEBUG_COMPOSITE)
					o.uv0.zw = bloomSpread;
				#endif
				#if defined(DEBUG_COMPOSITE) && defined(MK_LENS_SURFACE)
					o.MK_LENS_SURFACE_DIFFRACTION_UV = LensSurfaceDiffractionUV(o.uv0.xy);
				#endif
				#if defined(MK_LENS_FLARE) && defined(DEBUG_COMPOSITE) || defined(DEBUG_LENS_FLARE)
					o.LENS_FLARE_SPREAD = lensFlareSpread;
				#endif
				tristream.Append(o);

				o.pos = TransformMeshPos(SCREEN_VERTICES[1]);
				o.uv0.xy = SetMeshUV(o.pos.xy);
				#if defined(DEBUG_BLOOM) || defined(DEBUG_COMPOSITE)
					o.uv0.zw = bloomSpread;
				#endif
				#if defined(DEBUG_COMPOSITE) && defined(MK_LENS_SURFACE)
					o.MK_LENS_SURFACE_DIFFRACTION_UV = LensSurfaceDiffractionUV(o.uv0.xy);
				#endif
				#if defined(MK_LENS_FLARE) && defined(DEBUG_COMPOSITE) || defined(DEBUG_LENS_FLARE)
					o.LENS_FLARE_SPREAD = lensFlareSpread;
				#endif
				tristream.Append(o);

				o.pos = TransformMeshPos(SCREEN_VERTICES[2]);
				o.uv0.xy = SetMeshUV(o.pos.xy);
				#if defined(DEBUG_BLOOM) || defined(DEBUG_COMPOSITE)
					o.uv0.zw = bloomSpread;
				#endif
				#if defined(DEBUG_COMPOSITE) && defined(MK_LENS_SURFACE)
					o.MK_LENS_SURFACE_DIFFRACTION_UV = LensSurfaceDiffractionUV(o.uv0.xy);
				#endif
				#if defined(MK_LENS_FLARE) && defined(DEBUG_COMPOSITE) || defined(DEBUG_LENS_FLARE)
					o.LENS_FLARE_SPREAD = lensFlareSpread;
				#endif
				tristream.Append(o);
			}
		#endif
	#endif

	#if defined(DEBUG_RAW_BLOOM) || defined(DEBUG_RAW_LENS_FLARE) || defined(DEBUG_RAW_GLARE)
		#ifndef COMPUTE_SHADER
			#define HEADER half4 frag (VertGeoOutput o) : SV_Target
		#endif
	#endif
	#ifdef DEBUG_RAW_BLOOM
		#ifdef COMPUTE_SHADER
			#define HEADER [numthreads(8,8,1)] void DebugRawBloom (uint2 id : SV_DispatchThreadID)
		#endif
		HEADER
		{
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
			RETURN_TARGET_TEX ConvertToColorSpace(half4(LuminanceThreshold(SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), UV_0).rgb, BLOOM_THRESHOLD, LUMA_SCALE), 1));
		}
	#elif defined(DEBUG_RAW_LENS_FLARE)
		#ifdef COMPUTE_SHADER
			#define HEADER [numthreads(8,8,1)] void DebugRawLensFlare (uint2 id : SV_DispatchThreadID)
		#endif
		HEADER
		{
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
			RETURN_TARGET_TEX ConvertToColorSpace(half4(LuminanceThreshold(SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), UV_0).rgb, LENS_FLARE_THRESHOLD, LUMA_SCALE), 1));
		}
	#elif defined(DEBUG_RAW_GLARE)
		#ifdef COMPUTE_SHADER
			#define HEADER [numthreads(8,8,1)] void DebugRawGlare (uint2 id : SV_DispatchThreadID)
		#endif
		HEADER
		{
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
			RETURN_TARGET_TEX ConvertToColorSpace(half4(LuminanceThreshold(SampleTex2D(PASS_TEXTURE_2D(_SourceTex, sampler_SourceTex), UV_0).rgb, GLARE_THRESHOLD, LUMA_SCALE), 1));
		}
	#elif defined(DEBUG_GLARE)
		#ifdef COMPUTE_SHADER	
			#define HEADER [numthreads(8,8,1)] void DebugGlare (uint2 id : SV_DispatchThreadID)
		#else
			#define HEADER half4 frag (VertGeoOutputSimple o) : SV_Target
		#endif
		HEADER
		{
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);			
			half4 glare = GaussianBlur1D(PASS_TEXTURE_2D(_Glare0Tex, sampler_Glare0Tex), UV_0, GLARE0_TEX_TEXEL_SIZE * RESOLUTION_SCALE, GLARE0_DIFFUSION, GLARE0_DIRECTION, GLARE0_OFFSET) * GLARE0_INTENSITY;
			glare += GaussianBlur1D(PASS_TEXTURE_2D(_Glare1Tex, sampler_Glare1Tex), UV_0, GLARE0_TEX_TEXEL_SIZE * RESOLUTION_SCALE, GLARE1_DIFFUSION, GLARE1_DIRECTION, GLARE1_OFFSET) * GLARE1_INTENSITY;
			glare += GaussianBlur1D(PASS_TEXTURE_2D(_Glare2Tex, sampler_Glare2Tex), UV_0, GLARE0_TEX_TEXEL_SIZE * RESOLUTION_SCALE, GLARE2_DIFFUSION, GLARE2_DIRECTION, GLARE2_OFFSET) * GLARE2_INTENSITY;
			glare += GaussianBlur1D(PASS_TEXTURE_2D(_Glare3Tex, sampler_Glare3Tex), UV_0, GLARE0_TEX_TEXEL_SIZE * RESOLUTION_SCALE, GLARE3_DIFFUSION, GLARE3_DIRECTION, GLARE3_OFFSET) * GLARE3_INTENSITY;

			glare.rgb = lerp(0, glare.rgb, GLARE_BLEND);

			glare.rgb = Blooming(glare.rgb, BLOOMING);

			RETURN_TARGET_TEX ConvertToColorSpace(glare);
		}
	#elif defined(DEBUG_LENS_FLARE)
		#ifdef COMPUTE_SHADER
			#define HEADER [numthreads(8,8,1)] void DebugLensFlare (uint2 id : SV_DispatchThreadID)
		#else
			#define HEADER half4 frag (VertGeoOutput o) : SV_Target
		#endif
		HEADER
		{
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
			RETURN_TARGET_TEX ConvertToColorSpace(SampleTex2DCircularChromaticAberration(PASS_TEXTURE_2D(_LensFlareTex, sampler_LensFlareTex), UV_0, LENS_FLARE_CHROMATIC_ABERRATION));
		}
	#elif defined(DEBUG_COMPOSITE)
		#ifdef COMPUTE_SHADER
			#define HEADER [numthreads(8,8,1)] void DebugComposite (uint2 id : SV_DispatchThreadID)
		#else
			#define HEADER half4 frag (VertGeoOutput o) : SV_Target
		#endif

		HEADER
		{
			#include "CompositeSample.hlsl"
		}
	#else
		#ifdef COMPUTE_SHADER
			#define HEADER [numthreads(8,8,1)] void DebugBloom (uint2 id : SV_DispatchThreadID)
		#else
			#define HEADER half4 frag (VertGeoOutput o) : SV_Target
		#endif
		HEADER
		{
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
			half4 g = UpsampleHQ(PASS_TEXTURE_2D(_BloomTex, sampler_BloomTex), UV_0, BLOOM_TEXEL_SIZE * _BloomSpread) * BLOOM_INTENSITY;

			g.rgb = Blooming(g.rgb, BLOOMING);

			RETURN_TARGET_TEX ConvertToColorSpace(g);
		}
	#endif
#endif