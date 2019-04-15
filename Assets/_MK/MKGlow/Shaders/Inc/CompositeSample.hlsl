//////////////////////////////////////////////////////
// MK Glow Composite Sample							//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
#ifndef MK_GLOW_COMPOSITE_SAMPLE
	#define MK_GLOW_COMPOSITE_SAMPLE
	
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);
	
	#ifndef COMPUTE_SHADER
		FragmentOutputAuto fO;
		UNITY_INITIALIZE_OUTPUT(FragmentOutputAuto, fO);
	#endif
	#ifdef TARGET_LQ
		half4 g = SampleTex2D(PASS_TEXTURE_2D(_BloomTex, sampler_BloomTex), UV_0) * BLOOM_INTENSITY;
	#else
		half4 g = UpsampleHQ(PASS_TEXTURE_2D(_BloomTex, sampler_BloomTex), UV_0, BLOOM_COMPOSITE_SPREAD) * BLOOM_INTENSITY;
	#endif

	#ifdef MK_GLARE
		half4 glare = GaussianBlur1D(PASS_TEXTURE_2D(_Glare0Tex, sampler_Glare0Tex), UV_0, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE0_DIFFUSION, GLARE0_DIRECTION, GLARE0_OFFSET) * GLARE0_INTENSITY;
		glare += GaussianBlur1D(PASS_TEXTURE_2D(_Glare1Tex, sampler_Glare1Tex), UV_0, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE1_DIFFUSION, GLARE1_DIRECTION, GLARE1_OFFSET) * GLARE1_INTENSITY;
		glare += GaussianBlur1D(PASS_TEXTURE_2D(_Glare2Tex, sampler_Glare2Tex), UV_0, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE2_DIFFUSION, GLARE2_DIRECTION, GLARE2_OFFSET) * GLARE2_INTENSITY;
		glare += GaussianBlur1D(PASS_TEXTURE_2D(_Glare3Tex, sampler_Glare3Tex), UV_0, GLARE0_TEXEL_SIZE * RESOLUTION_SCALE, GLARE3_DIFFUSION, GLARE3_DIRECTION, GLARE3_OFFSET) * GLARE3_INTENSITY;

		g.rgb = max(0, lerp(g.rgb, glare.rgb, GLARE_BLEND));
	#endif

	g.rgb = Blooming(g.rgb, BLOOMING);

	#ifdef MK_LENS_FLARE
		g.rgb += SampleTex2DCircularChromaticAberration(PASS_TEXTURE_2D(_LensFlareTex, sampler_LensFlareTex), UV_0, LENS_FLARE_CHROMATIC_ABERRATION).rgb;
	#endif

	#ifdef MK_LENS_SURFACE
		half3 dirt = SampleTex2DNoScale(PASS_TEXTURE_2D(_LensSurfaceDirtTex, sampler_LensSurfaceDirtTex), LENS_SURFACE_DIRT_UV).rgb * LENS_SURFACE_DIRT_INTENSITY;
		half3 diffraction = SampleTex2DNoScale(PASS_TEXTURE_2D(_LensSurfaceDiffractionTex, sampler_LensSurfaceDiffractionTex), LENS_DIFFRACTION_UV).rgb * LENS_SURFACE_DIFFRACTION_INTENSITY;
		g.rgb = lerp(g.rgb * 3, g.rgb + g.rgb * dirt + g.rgb * diffraction, 0.5) * 0.3333h;
	#endif
	
	//When using gamma space at least try to get a nice looking result by adding the glow in the linear space of the source even if the base color space is gamma
	#ifdef MK_GLOW_COMPOSITE
		#ifdef COLORSPACE_GAMMA
			g.rgb += GammaToLinearSpace(SAMPLE_SOURCE.rgb).rgb;
			RETURN_TARGET_TEX ConvertToColorSpace(g);
		#else
			g.rgb += SAMPLE_SOURCE.rgb;
			RETURN_TARGET_TEX g;
		#endif
	#else
		RETURN_TARGET_TEX ConvertToColorSpace(g);
	#endif
#endif