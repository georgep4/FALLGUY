//////////////////////////////////////////////////////
// MK Glow 	    	    	                        //
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace MK.Glow.Legacy
{
	#if UNITY_2018_3_OR_NEWER
        [ExecuteAlways]
    #else
        [ExecuteInEditMode]
    #endif
    [DisallowMultipleComponent]
    [ImageEffectAllowedInSceneView]
    [RequireComponent(typeof(Camera))]
	public class MKGlow : MonoBehaviour
	{
        #if UNITY_EDITOR
        public bool showEditorMainBehavior = true;
		public bool showEditorBloomBehavior;
		public bool showEditorLensSurfaceBehavior;
		public bool showEditorLensFlareBehavior;
		public bool showEditorGlareBehavior;
        #endif

        //Main
        public bool allowGeometryShaders = true;
        public bool allowComputeShaders = true;
        public DebugView debugView = MK.Glow.DebugView.None;
        public Quality quality = MK.Glow.Quality.High;
        public Workflow workflow = MK.Glow.Workflow.Luminance;
        public LayerMask selectiveRenderLayerMask = -1;
        [Range(-1f, 1f)]
        public float anamorphicRatio = 0f;
        [Range(0f, 1f)]
        public float lumaScale = 0.5f;
        [Range(0f, 1f)]
		public float blooming = 0f;

        //Bloom
        [MK.Glow.MinMaxRange(0, 10)]
        public MinMaxRange bloomThreshold = new MinMaxRange(1.0f, 10f);
        [Range(1f, 10f)]
		public float bloomScattering = 7f;
		public float bloomIntensity = 1f;

        //LensSurface
        public bool allowLensSurface = false;
		public Texture2D lensSurfaceDirtTexture;
		public float lensSurfaceDirtIntensity = 2.5f;
		public Texture2D lensSurfaceDiffractionTexture;
		public float lensSurfaceDiffractionIntensity = 2.0f;

        //LensFlare
        public bool allowLensFlare = false;
        [Range(0f, 25f)]
		public float lensFlareGhostFade = 10.0f;
		public float lensFlareGhostIntensity = 1.0f;
        [MK.Glow.MinMaxRange(0, 10)]
		public MinMaxRange lensFlareThreshold = new MinMaxRange(1.3f, 10f);
        [Range(0f, 8f)]
		public float lensFlareScattering = 5f;
		public Texture2D lensFlareColorRamp;
        [Range(-100f, 100f)]
		public float lensFlareChromaticAberration = 53f;
        [Range(1, 4)]
		public int lensFlareGhostCount = 3;
        [Range(-1f, 1f)]
		public float lensFlareGhostDispersal = 0.6f;
        [Range(0f, 10f)]
		public float lensFlareHaloFade = 2f;
		public float lensFlareHaloIntensity = 1.0f;
        [Range(0f, 1f)]
		public float lensFlareHaloSize = 0.4f;

        //Glare
        public bool allowGlare = false;
        [Range(0.0f, 1.0f)]
        public float glareBlend = 0.33f;
        [MK.Glow.MinMaxRange(0, 10)]
        public MinMaxRange glareThreshold = new MinMaxRange(1.0f, 10f);
        //Sample0
        [Range(0f, 10f)]
        public float glareSample0Scattering = 5f;
        [Range(0f, 360f)]
        public float glareSample0Angle = 0f;
        public float glareSample0Intensity = 1f;
        [Range(-5f, 5f)]
        public float glareSample0Offset = 0f;
        //Sample1
        [Range(0f, 10f)]
        public float glareSample1Scattering = 5f;
        [Range(0f, 360f)]
        public float glareSample1Angle = 45f;
        public float glareSample1Intensity = 1f;
        [Range(-5f, 5f)]
        public float glareSample1Offset = 0f;
        //Sample0
        [Range(0f, 10f)]
        public float glareSample2Scattering = 5f;
        [Range(0f, 360f)]
        public float glareSample2Angle = 90f;
        public float glareSample2Intensity = 1f;
        [Range(-5f, 5f)]
        public float glareSample2Offset = 0f;
        //Sample0
        [Range(0f, 10f)]
        public float glareSample3Scattering = 5f;
        [Range(0f, 360f)]
        public float glareSample3Angle = 135f;
        public float glareSample3Intensity = 1f;
        [Range(-5f, 5f)]
        public float glareSample3Offset = 0f;

        private Effect _effect;

        private RenderTarget _source, _destination;
        private RenderTexture _tmpTexture;
        private RenderContext _tmpContext;
        private RenderDimension _tmpDimension = new RenderDimension();

		private Camera renderingCamera
		{
			get { return GetComponent<Camera>(); }
		}

		public void OnEnable()
		{
            _effect = new Effect();
            _tmpContext = new RenderContext();
			_effect.Enable(RenderPipeline.Legacy);
		}

		public void OnDisable()
		{
			_effect.Disable();
		}

        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if(workflow == Workflow.Selective && PipelineProperties.xrEnabled)
            {
                Graphics.Blit(source, destination);
                return;
            }
            
            _tmpDimension.width = renderingCamera.pixelWidth;
            _tmpDimension.height = renderingCamera.pixelHeight;

            _tmpContext.UpdateRenderContext(renderingCamera, _effect.renderTextureFormat, source.depth, false, _tmpDimension);
            _tmpTexture = PipelineExtensions.GetTemporary(_tmpContext, _effect.renderTextureFormat);

            _source.renderTexture = source;
            _destination.renderTexture = _tmpTexture;
			_effect.Build(_source, _destination, this, null, renderingCamera);

            Graphics.Blit(_destination.renderTexture, destination);
            RenderTexture.ReleaseTemporary(_tmpTexture);
        }
	}
}