//////////////////////////////////////////////////////
// MK Glow Upsample									//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////

#ifndef MK_GLOW_UPSAMPLE
	#define MK_GLOW_UPSAMPLE

	#include "../Inc/Common.hlsl"

	#ifdef MK_BLOOM
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_BloomTex)
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_HigherMipBloomTex)
		#ifdef COMPUTE_SHADER
			UNIFORM_RWTEXTURE_2D(_BloomTargetTex)
		#else
			uniform float _BloomSpread;
			uniform float2 _BloomTex_TexelSize;
			uniform float2 _HigherMipBloomTex_TexelSize;
		#endif
	#endif

	#ifdef MK_LENS_FLARE
		UNIFORM_SAMPLER_AND_TEXTURE_2D(_LensFlareTex)
		#ifdef COMPUTE_SHADER
			UNIFORM_RWTEXTURE_2D(_LensFlareTargetTex)
		#else
			uniform float2 _LensFlareTex_TexelSize;
			uniform float _LensFlareSpread;
		#endif
	#endif

	#ifdef MK_GLARE
		#ifdef COMPUTE_SHADER
			UNIFORM_RWTEXTURE_2D(_Glare0TargetTex)
			UNIFORM_RWTEXTURE_2D(_Glare1TargetTex)
			UNIFORM_RWTEXTURE_2D(_Glare2TargetTex)
			UNIFORM_RWTEXTURE_2D(_Glare3TargetTex)
		#else
			uniform float2 _Glare0Tex_TexelSize;
			uniform float2 _ResolutionScale;

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

	#ifndef COMPUTE_SHADER
		#if defined(MK_BLOOM) && defined(MK_LENS_FLARE)
			#define VERT_GEO_OUTPUT VertGeoOutputPlus
			#define BLOOM_SPREAD uv0.zw
			#define LENS_FLARE_SPREAD uv1.xy
		#elif defined(MK_BLOOM) || defined(MK_LENS_FLARE)
			#define VERT_GEO_OUTPUT VertGeoOutputAdvanced
			#define BLOOM_SPREAD uv0.zw
			#define LENS_FLARE_SPREAD uv0.zw
		#else
			#define VERT_GEO_OUTPUT VertGeoOutputSimple
		#endif

		VERT_GEO_OUTPUT vert (VertexInputOnlyPosition i0)
		{
			VERT_GEO_OUTPUT o;
			UNITY_SETUP_INSTANCE_ID(i0);
			UNITY_INITIALIZE_OUTPUT(VERT_GEO_OUTPUT, o);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

			o.pos = TransformMeshPos(i0.vertex);
			o.uv0.xy = SetMeshUV(i0.vertex.xy);
			
			#ifdef MK_BLOOM
				o.BLOOM_SPREAD = BLOOM_TEXEL_SIZE * _BloomSpread;
			#endif

			#ifdef MK_LENS_FLARE
				o.LENS_FLARE_SPREAD = LENS_FLARE_TEXEL_SIZE * _LensFlareSpread;
			#endif

			return o;
		}

		#ifdef GEOMETRY_SHADER
			[maxvertexcount(3)]
			void geom(point VertexInputEmpty i0[1], inout TriangleStream<VERT_GEO_OUTPUT> tristream)
			{
				VERT_GEO_OUTPUT o;
				UNITY_INITIALIZE_OUTPUT(VERT_GEO_OUTPUT, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i0[0], o);

				#ifdef MK_BLOOM
					float2 bloomSpread = BLOOM_TEXEL_SIZE * _BloomSpread;
				#endif
				#ifdef MK_LENS_FLARE
					float2 lensFlareSpread = LENS_FLARE_TEXEL_SIZE * _LensFlareSpread;
				#endif

				o.pos = TransformMeshPos(SCREEN_VERTICES[0]);
				o.uv0.xy = SetMeshUV(o.pos.xy);
				#ifdef MK_BLOOM
					o.BLOOM_SPREAD = bloomSpread;
				#endif
				#ifdef MK_LENS_FLARE
					o.LENS_FLARE_SPREAD = lensFlareSpread;
				#endif
				tristream.Append(o);

				o.pos = TransformMeshPos(SCREEN_VERTICES[1]);
				o.uv0.xy = SetMeshUV(o.pos.xy);
				#ifdef MK_BLOOM
					o.BLOOM_SPREAD = bloomSpread;
				#endif
				#ifdef MK_LENS_FLARE
					o.LENS_FLARE_SPREAD = lensFlareSpread;
				#endif
				tristream.Append(o);

				o.pos = TransformMeshPos(SCREEN_VERTICES[2]);
				o.uv0.xy = SetMeshUV(o.pos.xy);
				#ifdef MK_BLOOM
					o.BLOOM_SPREAD = bloomSpread;
				#endif
				#ifdef MK_LENS_FLARE
					o.LENS_FLARE_SPREAD = lensFlareSpread;
				#endif
				tristream.Append(o);
			}
		#endif
	#endif
		
	#ifdef COMPUTE_SHADER
		#define HEADER [numthreads(8,8,1)] void Upsample (uint2 id : SV_DispatchThreadID)
	#else
		#define HEADER FragmentOutputAuto frag (VERT_GEO_OUTPUT o)
	#endif

	HEADER
	{
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
		
		#ifndef COMPUTE_SHADER
			FragmentOutputAuto fO;
			UNITY_INITIALIZE_OUTPUT(FragmentOutputAuto, fO);
		#endif

		#ifdef MK_BLOOM
			BLOOM_RENDER_TARGET = UpsampleHQ(PASS_TEXTURE_2D(_BloomTex, sampler_BloomTex), BLOOM_UV, BLOOM_UPSAMPLE_SPREAD);
			BLOOM_RENDER_TARGET += half4(SampleTex2D(PASS_TEXTURE_2D(_HigherMipBloomTex, sampler_HigherMipBloomTex), BLOOM_UV).rgb, 0);
		#endif

		#ifdef MK_LENS_FLARE
			LENS_FLARE_RENDER_TARGET = UpsampleLQ(PASS_TEXTURE_2D(_LensFlareTex, sampler_LensFlareTex), LENS_FLARE_UV, LENS_FLARE_UPSAMPLE_SPREAD);
		#endif
		
		//TODO: move texcoordcalculation to vertexshader
		#ifdef MK_GLARE
			GLARE0_RENDER_TARGET = GaussianBlur1D(PASS_TEXTURE_2D(_Glare0Tex, sampler_Glare0Tex), GLARE_UV, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE0_DIFFUSION, GLARE0_DIRECTION, GLARE0_OFFSET);
			GLARE1_RENDER_TARGET = GaussianBlur1D(PASS_TEXTURE_2D(_Glare1Tex, sampler_Glare1Tex), GLARE_UV, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE1_DIFFUSION, GLARE1_DIRECTION, GLARE1_OFFSET);
			GLARE2_RENDER_TARGET = GaussianBlur1D(PASS_TEXTURE_2D(_Glare2Tex, sampler_Glare2Tex), GLARE_UV, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE2_DIFFUSION, GLARE2_DIRECTION, GLARE2_OFFSET);
			GLARE3_RENDER_TARGET = GaussianBlur1D(PASS_TEXTURE_2D(_Glare3Tex, sampler_Glare3Tex), GLARE_UV, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE3_DIFFUSION, GLARE3_DIRECTION, GLARE3_OFFSET);
		#endif

		#ifndef COMPUTE_SHADER
			return fO;
		#endif
	}
#endif