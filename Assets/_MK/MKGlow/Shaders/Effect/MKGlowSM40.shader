//////////////////////////////////////////////////////
// MK Glow Shader SM40								//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
Shader "Hidden/MK/Glow/MKGlowSM40"
{
	SubShader
	{
		Tags {"LightMode" = "Always" "RenderType"="Opaque" "PerformanceChecks"="False"}
		Cull Off ZWrite Off ZTest Always

		/////////////////////////////////////////////////////////////////////////////////////////////
        // Copy - 0
        /////////////////////////////////////////////////////////////////////////////////////////////
		Pass
		{
			HLSLPROGRAM
			#pragma target 4.0
			#pragma vertex vertSimple
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma exclude_renderers metal nomrt

			#include "../Inc/Copy.hlsl"
			ENDHLSL
		}

		/////////////////////////////////////////////////////////////////////////////////////////////
        // Presample - 1
        /////////////////////////////////////////////////////////////////////////////////////////////
		Pass
		{
			HLSLPROGRAM
			#pragma target 4.0
			#pragma vertex vertSimple
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma exclude_renderers metal nomrt

			#pragma multi_compile __ _NORMALMAP
			#pragma multi_compile __ _ALPHABLEND_ON
			#pragma multi_compile __ _ALPHAPREMULTIPLY_ON

			#include "../Inc/Presample.hlsl"
			ENDHLSL
		}

		/////////////////////////////////////////////////////////////////////////////////////////////
        // Downsample - 2
        /////////////////////////////////////////////////////////////////////////////////////////////
		Pass
		{
			HLSLPROGRAM
			#pragma target 4.0
			#pragma vertex vertSimple
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma exclude_renderers metal nomrt

			#pragma multi_compile __ _NORMALMAP
			#pragma multi_compile __ _ALPHABLEND_ON
			#pragma multi_compile __ _ALPHAPREMULTIPLY_ON

			#include "../Inc/Downsample.hlsl"
			ENDHLSL
		}

		/////////////////////////////////////////////////////////////////////////////////////////////
        // Upsample - 3
        /////////////////////////////////////////////////////////////////////////////////////////////
		Pass
		{
			HLSLPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma exclude_renderers metal nomrt

			#pragma multi_compile __ _NORMALMAP
			#pragma multi_compile __ _ALPHABLEND_ON
			#pragma multi_compile __ _ALPHAPREMULTIPLY_ON

			#include "../Inc/Upsample.hlsl"
			ENDHLSL
		}

		/////////////////////////////////////////////////////////////////////////////////////////////
        // Composite - 4
        /////////////////////////////////////////////////////////////////////////////////////////////
		Pass
		{
			HLSLPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma exclude_renderers metal nomrt

			#pragma multi_compile __ _ALPHATEST_ON
			#pragma multi_compile __ _ALPHABLEND_ON
			#pragma multi_compile __ _ALPHAPREMULTIPLY_ON

			#include "../Inc/Composite.hlsl"
			ENDHLSL
		}

		/////////////////////////////////////////////////////////////////////////////////////////////
        // Debug - 5
        /////////////////////////////////////////////////////////////////////////////////////////////
		Pass
		{
			HLSLPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma exclude_renderers metal nomrt
			
			#pragma multi_compile __ _EMISSION _METALLICGLOSSMAP _DETAIL_MULX2 _SPECULARHIGHLIGHTS_OFF _GLOSSYREFLECTIONS_OFF EDITOR_VISUALIZATION
			#pragma multi_compile __ _ALPHATEST_ON
			#pragma multi_compile __ _ALPHABLEND_ON
			#pragma multi_compile __ _ALPHAPREMULTIPLY_ON
			
			#include "../Inc/Debug.hlsl"
			ENDHLSL
		}
	}
	FallBack "Hidden/MK/Glow/MKGlowSM35"
}
