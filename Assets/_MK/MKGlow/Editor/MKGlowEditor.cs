//////////////////////////////////////////////////////
// MK Glow Editor Postprocessing Stack	      		//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
#if UNITY_POST_PROCESSING_STACK_V2
using UnityEngine.Rendering.PostProcessing;
using UnityEditor.Rendering.PostProcessing;
using MK.Glow;
using UnityEditor;
using UnityEngine;

namespace MK.Glow.Editor
{
	using Tooltips = EditorHelper.EditorUIContent.Tooltips;

	[PostProcessEditor(typeof(MK.Glow.MKGlow))]
	internal class MKGlowEditor : PostProcessEffectEditor<MK.Glow.MKGlow>
	{
		//Behaviors
		private SerializedProperty _showEditorMainBehavior;
		private SerializedProperty _showEditorBloomBehavior;
		private SerializedProperty _showEditorLensSurfaceBehavior;
		private SerializedProperty _showEditorLensFlareBehavior;
		private SerializedProperty _showEditorGlareBehavior;
		private SerializedProperty _isInitialized;

		//Main
		private SerializedParameterOverride _allowGeometryShaders;
		private SerializedParameterOverride _allowComputeShaders;
		private SerializedParameterOverride _debugView;
		private SerializedParameterOverride _quality;
		private SerializedParameterOverride _workflow;
		private SerializedParameterOverride _selectiveRenderLayerMask;
		private SerializedParameterOverride _anamorphicRatio;
		private SerializedParameterOverride _lumaScale;
		private SerializedParameterOverride _blooming;

		//Bloom
		private SerializedParameterOverride _bloomThreshold;
		private SerializedParameterOverride _bloomScattering;
		private SerializedParameterOverride _bloomIntensity;

		//Lens Surface
		private SerializedParameterOverride _allowLensSurface;
		private SerializedParameterOverride _lensSurfaceDirtTexture;
		private SerializedParameterOverride _lensSurfaceDirtIntensity;
		private SerializedParameterOverride _lensSurfaceDiffractionTexture;
		private SerializedParameterOverride _lensSurfaceDiffractionIntensity;

		//Lens Flare
		private SerializedParameterOverride _allowLensflare;
		private SerializedParameterOverride _lensFlareGhostFade;
		private SerializedParameterOverride _lensFlareGhostIntensity;
		private SerializedParameterOverride _lensFlareThreshold;
		private SerializedParameterOverride _lensFlareScattering;
		private SerializedParameterOverride _lensFlareColorRamp;
		private SerializedParameterOverride _lensFlareChromaticAberration;
		private SerializedParameterOverride _lensFlareGhostCount;
		private SerializedParameterOverride _lensFlareGhostDispersal;
		private SerializedParameterOverride _lensFlareHaloFade;
		private SerializedParameterOverride _lensFlareHaloIntensity;
		private SerializedParameterOverride _lensFlareHaloSize;

		//Glare
		private SerializedParameterOverride _allowGlare;
		private SerializedParameterOverride _glareBlend;
		private SerializedParameterOverride _glareThreshold;
		private SerializedParameterOverride _glareSample0Scattering;
		private SerializedParameterOverride _glareSample0Intensity;
		private SerializedParameterOverride _glareSample0Angle;
		private SerializedParameterOverride _glareSample0Offset;
		private SerializedParameterOverride _glareSample1Scattering;
		private SerializedParameterOverride _glareSample1Intensity;
		private SerializedParameterOverride _glareSample1Angle;
		private SerializedParameterOverride _glareSample1Offset;
		private SerializedParameterOverride _glareSample2Scattering;
		private SerializedParameterOverride _glareSample2Intensity;
		private SerializedParameterOverride _glareSample2Angle;
		private SerializedParameterOverride _glareSample2Offset;
		private SerializedParameterOverride _glareSample3Scattering;
		private SerializedParameterOverride _glareSample3Intensity;
		private SerializedParameterOverride _glareSample3Angle;
		private SerializedParameterOverride _glareSample3Offset;

		public override void OnEnable()
		{
			//Editor
			_showEditorMainBehavior = FindProperty(x => x.showEditorMainBehavior);
			_showEditorBloomBehavior = FindProperty(x => x.showEditorBloomBehavior);
			_showEditorLensSurfaceBehavior = FindProperty(x => x.showEditorLensSurfaceBehavior);
			_showEditorLensFlareBehavior = FindProperty(x => x.showEditorLensFlareBehavior);
			_showEditorGlareBehavior = FindProperty(x => x.showEditorGlareBehavior);
			_isInitialized = FindProperty(x => x.isInitialized);

			//Main
			_allowGeometryShaders = FindParameterOverride(x => x.allowGeometryShaders);
			_allowComputeShaders = FindParameterOverride(x => x.allowComputeShaders);
			_debugView = FindParameterOverride(x => x.debugView);
			_quality = FindParameterOverride(x => x.quality);
			_workflow = FindParameterOverride(x => x.workflow);
			_selectiveRenderLayerMask = FindParameterOverride(x => x.selectiveRenderLayerMask);
			_anamorphicRatio = FindParameterOverride(x => x.anamorphicRatio);
			_lumaScale = FindParameterOverride(x => x.lumaScale);
			_blooming = FindParameterOverride(x => x.blooming);

			//Bloom
			_bloomThreshold = FindParameterOverride(x => x.bloomThreshold);
			_bloomScattering = FindParameterOverride(x => x.bloomScattering);
			_bloomIntensity = FindParameterOverride(x => x.bloomIntensity);

			_allowLensSurface = FindParameterOverride(x => x.allowLensSurface);
			_lensSurfaceDirtTexture = FindParameterOverride(x => x.lensSurfaceDirtTexture);
			_lensSurfaceDirtIntensity = FindParameterOverride(x => x.lensSurfaceDirtIntensity);
			_lensSurfaceDiffractionTexture = FindParameterOverride(x => x.lensSurfaceDiffractionTexture);
			_lensSurfaceDiffractionIntensity = FindParameterOverride(x => x.lensSurfaceDiffractionIntensity);

			_allowLensflare = FindParameterOverride(x => x.allowLensFlare);
			_lensFlareGhostFade = FindParameterOverride(x => x.lensFlareGhostFade);
			_lensFlareGhostIntensity = FindParameterOverride(x => x.lensFlareGhostIntensity);
			_lensFlareThreshold = FindParameterOverride(x => x.lensFlareThreshold);
			_lensFlareScattering = FindParameterOverride(x => x.lensFlareScattering);
			_lensFlareColorRamp = FindParameterOverride(x => x.lensFlareColorRamp);
			_lensFlareChromaticAberration = FindParameterOverride(x => x.lensFlareChromaticAberration);
			_lensFlareGhostCount = FindParameterOverride(x => x.lensFlareGhostCount);
			_lensFlareGhostDispersal = FindParameterOverride(x => x.lensFlareGhostDispersal);
			_lensFlareHaloFade = FindParameterOverride(x => x.lensFlareHaloFade);
			_lensFlareHaloIntensity = FindParameterOverride(x => x.lensFlareHaloIntensity);
			_lensFlareHaloSize = FindParameterOverride(x => x.lensFlareHaloSize);

			_allowGlare = FindParameterOverride(x => x.allowGlare);
			_glareBlend = FindParameterOverride(x => x.glareBlend);
			_glareThreshold = FindParameterOverride(x => x.glareThreshold);
			_glareSample0Scattering = FindParameterOverride(x => x.glareSample0Scattering);
			_glareSample0Intensity = FindParameterOverride(x => x.glareSample0Intensity);
			_glareSample0Angle = FindParameterOverride(x => x.glareSample0Angle);
			_glareSample0Offset = FindParameterOverride(x => x.glareSample0Offset);
			_glareSample1Scattering = FindParameterOverride(x => x.glareSample1Scattering);
			_glareSample1Intensity = FindParameterOverride(x => x.glareSample1Intensity);
			_glareSample1Angle = FindParameterOverride(x => x.glareSample1Angle);
			_glareSample1Offset = FindParameterOverride(x => x.glareSample1Offset);
			_glareSample2Scattering = FindParameterOverride(x => x.glareSample2Scattering);
			_glareSample2Intensity = FindParameterOverride(x => x.glareSample2Intensity);
			_glareSample2Angle = FindParameterOverride(x => x.glareSample2Angle);
			_glareSample2Offset = FindParameterOverride(x => x.glareSample2Offset);
			_glareSample3Scattering = FindParameterOverride(x => x.glareSample3Scattering);
			_glareSample3Intensity = FindParameterOverride(x => x.glareSample3Intensity);
			_glareSample3Angle = FindParameterOverride(x => x.glareSample3Angle);
			_glareSample3Offset = FindParameterOverride(x => x.glareSample3Offset);
		}

		public override void OnInspectorGUI()
		{
			if(_isInitialized.boolValue == false)
			{
				_bloomIntensity.value.floatValue = 1f;
				_bloomIntensity.overrideState.boolValue = true;

				_lensSurfaceDirtIntensity.value.floatValue = 2.5f;
				_lensSurfaceDirtIntensity.overrideState.boolValue = true;
				_lensSurfaceDiffractionIntensity.value.floatValue = 2f;
				_lensSurfaceDiffractionIntensity.overrideState.boolValue = true;

				_lensFlareGhostIntensity.value.floatValue = 1.0f;
				_lensFlareGhostIntensity.overrideState.boolValue = true;
				_lensFlareHaloIntensity.value.floatValue = 1.0f;
				_lensFlareHaloIntensity.overrideState.boolValue = true;

				_glareSample0Intensity.value.floatValue = 1.0f;
				_glareSample0Intensity.overrideState.boolValue = true;
				_glareSample1Intensity.value.floatValue = 1.0f;
				_glareSample1Intensity.overrideState.boolValue = true;
				_glareSample2Intensity.value.floatValue = 1.0f;
				_glareSample2Intensity.overrideState.boolValue = true;
				_glareSample3Intensity.value.floatValue = 1.0f;
				_glareSample3Intensity.overrideState.boolValue = true;

				_isInitialized.boolValue = true;
			}

			EditorHelper.EditorUIContent.XRUnityVersionWarning();

			if(EditorHelper.HandleBehavior(_showEditorMainBehavior.serializedObject.targetObject, EditorHelper.EditorUIContent.mainTitle, "", _showEditorMainBehavior, null))
			{
				PropertyField(_allowGeometryShaders, Tooltips.allowGeometryShaders);
				PropertyField(_allowComputeShaders, Tooltips.allowComputeShaders);
				PropertyField(_debugView, Tooltips.debugView);
				PropertyField(_quality, Tooltips.quality);
				PropertyField(_workflow, Tooltips.workflow);
				EditorHelper.EditorUIContent.SelectiveWorkflowVRWarning((Workflow)_workflow.value.enumValueIndex);
                if(_workflow.value.enumValueIndex == 1)
                {
                    PropertyField(_selectiveRenderLayerMask, Tooltips.selectiveRenderLayerMask);
                }
				PropertyField(_anamorphicRatio, Tooltips.anamorphicRatio);
				PropertyField(_lumaScale, Tooltips.lumaScale);
				PropertyField(_blooming, Tooltips.blooming);
				EditorHelper.VerticalSpace();
			}
			
			if(EditorHelper.HandleBehavior(_showEditorBloomBehavior.serializedObject.targetObject, EditorHelper.EditorUIContent.bloomTitle, "", _showEditorBloomBehavior, null))
			{
				if(_workflow.value.enumValueIndex == 0)
					PropertyField(_bloomThreshold, Tooltips.bloomThreshold);
				PropertyField(_bloomScattering, Tooltips.bloomScattering);
				PropertyField(_bloomIntensity, Tooltips.bloomIntensity);
				_bloomIntensity.value.floatValue = Mathf.Max(0, _bloomIntensity.value.floatValue);

				EditorHelper.VerticalSpace();
			}

			if(EditorHelper.HandleBehavior(_showEditorLensSurfaceBehavior.serializedObject.targetObject, EditorHelper.EditorUIContent.lensSurfaceTitle, "", _showEditorLensSurfaceBehavior, _allowLensSurface.value))
			{
				using (new EditorGUI.DisabledScope(!_allowLensSurface.value.boolValue))
                {
					EditorHelper.DrawHeader(EditorHelper.EditorUIContent.dirtTitle);
					PropertyField(_lensSurfaceDirtTexture, Tooltips.lensSurfaceDirtTexture);
					PropertyField(_lensSurfaceDirtIntensity, Tooltips.lensSurfaceDirtIntensity);
					_lensSurfaceDirtIntensity.value.floatValue = Mathf.Max(0, _lensSurfaceDirtIntensity.value.floatValue);
					EditorGUILayout.Space();
					EditorHelper.DrawHeader(EditorHelper.EditorUIContent.diffractionTitle);
					PropertyField(_lensSurfaceDiffractionTexture, Tooltips.lensSurfaceDiffractionTexture);
					PropertyField(_lensSurfaceDiffractionIntensity, Tooltips.lensSurfaceDiffractionIntensity);
					_lensSurfaceDiffractionIntensity.value.floatValue = Mathf.Max(0, _lensSurfaceDiffractionIntensity.value.floatValue);
				}
				EditorHelper.VerticalSpace();
			}

			if(Compatibility.CheckLensFlareFeatureSupport())
			{
				if(EditorHelper.HandleBehavior(_showEditorLensFlareBehavior.serializedObject.targetObject, EditorHelper.EditorUIContent.lensFlareTitle, "", _showEditorLensFlareBehavior, _allowLensflare.value))
				{
					using (new EditorGUI.DisabledScope(!_allowLensflare.value.boolValue))
					{
						if(_workflow.value.enumValueIndex == 0)
							PropertyField(_lensFlareThreshold, Tooltips.lensFlareThreshold);
						PropertyField(_lensFlareScattering, Tooltips.lensFlareScattering);
						PropertyField(_lensFlareColorRamp, Tooltips.lensFlareColorRamp);
						PropertyField(_lensFlareChromaticAberration, Tooltips.lensFlareChromaticAberration);

						EditorGUILayout.Space();
						EditorHelper.DrawHeader(EditorHelper.EditorUIContent.ghostsTitle);
						PropertyField(_lensFlareGhostFade, Tooltips.lensFlareGhostFade);
						PropertyField(_lensFlareGhostCount, Tooltips.lensFlareGhostCount);
						PropertyField(_lensFlareGhostDispersal, Tooltips.lensFlareGhostDispersal);
						PropertyField(_lensFlareGhostIntensity, Tooltips.lensFlareGhostIntensity);
						_lensFlareGhostIntensity.value.floatValue = Mathf.Max(0, _lensFlareGhostIntensity.value.floatValue);

						EditorGUILayout.Space();
						EditorHelper.DrawHeader(EditorHelper.EditorUIContent.haloTitle);
						PropertyField(_lensFlareHaloFade, Tooltips.lensFlareHaloFade);
						PropertyField(_lensFlareHaloSize, Tooltips.lensFlareHaloSize);
						PropertyField(_lensFlareHaloIntensity, Tooltips.lensFlareHaloIntensity);
						_lensFlareHaloIntensity.value.floatValue = Mathf.Max(0, _lensFlareHaloIntensity.value.floatValue);
					}
					EditorHelper.VerticalSpace();
				}
			}
			else
			{
				EditorHelper.DrawSplitter();
				EditorHelper.EditorUIContent.LensFlareFeatureNotSupportedWarning();
			}

			if(Compatibility.CheckGlareFeatureSupport())
			{
				if(EditorHelper.HandleBehavior(_showEditorGlareBehavior.serializedObject.targetObject, EditorHelper.EditorUIContent.glareTitle, "", _showEditorGlareBehavior, _allowGlare.value))
				{
					using (new EditorGUI.DisabledScope(!_allowGlare.value.boolValue))
					{
						if(_workflow.value.enumValueIndex == 0)
							PropertyField(_glareThreshold, Tooltips.glareThreshold);
						PropertyField(_glareBlend, Tooltips.glareBlend);

						EditorGUILayout.Space();
						EditorHelper.DrawHeader(EditorHelper.EditorUIContent.sample0Title);
						PropertyField(_glareSample0Scattering, Tooltips.glareSample0Scattering);
						PropertyField(_glareSample0Angle, Tooltips.glareSample0Angle);
						PropertyField(_glareSample0Offset, Tooltips.glareSample0Offset);
						PropertyField(_glareSample0Intensity, Tooltips.glareSample0Intensity);
						_glareSample0Intensity.value.floatValue = Mathf.Max(0, _glareSample0Intensity.value.floatValue);
						
						EditorGUILayout.Space();
						EditorHelper.DrawHeader(EditorHelper.EditorUIContent.sample1Title);
						PropertyField(_glareSample1Scattering, Tooltips.glareSample1Scattering);
						PropertyField(_glareSample1Angle, Tooltips.glareSample1Angle);
						PropertyField(_glareSample1Offset, Tooltips.glareSample1Offset);
						PropertyField(_glareSample1Intensity, Tooltips.glareSample1Intensity);
						_glareSample1Intensity.value.floatValue = Mathf.Max(0, _glareSample1Intensity.value.floatValue);

						EditorGUILayout.Space();
						EditorHelper.DrawHeader(EditorHelper.EditorUIContent.sample2Title);
						PropertyField(_glareSample2Scattering, Tooltips.glareSample2Scattering);
						PropertyField(_glareSample2Angle, Tooltips.glareSample2Angle);
						PropertyField(_glareSample2Offset, Tooltips.glareSample2Offset);
						PropertyField(_glareSample2Intensity, Tooltips.glareSample2Intensity);
						_glareSample2Intensity.value.floatValue = Mathf.Max(0, _glareSample2Intensity.value.floatValue);
						
						EditorGUILayout.Space();
						EditorHelper.DrawHeader(EditorHelper.EditorUIContent.sample3Title);
						PropertyField(_glareSample3Scattering, Tooltips.glareSample3Scattering);
						PropertyField(_glareSample3Angle, Tooltips.glareSample3Angle);
						PropertyField(_glareSample3Offset, Tooltips.glareSample3Offset);
						PropertyField(_glareSample3Intensity, Tooltips.glareSample3Intensity);
						_glareSample3Intensity.value.floatValue = Mathf.Max(0, _glareSample3Intensity.value.floatValue);
					}
					EditorHelper.VerticalSpace();
				}
			}
			else
			{
				EditorHelper.DrawSplitter();
				EditorHelper.EditorUIContent.GlareFeatureNotSupportedWarning();
			}
			EditorHelper.DrawSplitter();
		}
    }
}
#endif