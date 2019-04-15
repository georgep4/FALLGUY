//////////////////////////////////////////////////////
// MK Glow PostProcessing Stack     	            //
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using System.Collections;
using System.Collections.Generic;

namespace MK.Glow
{
    [Serializable]
    [PostProcess(typeof(MKGlowRenderer), PostProcessEvent.BeforeStack, "MK/MK Glow")]
    public sealed class MKGlow : PostProcessEffectSettings
    {
        [System.Serializable]
        public sealed class Texture2DParameter : ParameterOverride<Texture2D>
        {
            public override void Interp(Texture2D from, Texture2D to, float t)
            {
                value = t > 0 ? to : from;
            }
        }

        [System.Serializable]
        public sealed class DebugViewParameter : ParameterOverride<MK.Glow.DebugView>
        {
            public override void Interp(MK.Glow.DebugView from, MK.Glow.DebugView to, float t)
            {
                value = t > 0 ? to : from;
            }
        }

        [System.Serializable]
        public sealed class QualityParameter : ParameterOverride<MK.Glow.Quality>
        {
            public override void Interp(MK.Glow.Quality from, MK.Glow.Quality to, float t)
            {
                value = t > 0 ? to : from;
            }
        }

        [System.Serializable]
        public sealed class WorkflowParameter : ParameterOverride<MK.Glow.Workflow>
        {
            public override void Interp(MK.Glow.Workflow from, MK.Glow.Workflow to, float t)
            {
                value = t > 0 ? to : from;
            }
        }

        [System.Serializable]
        public sealed class LayerMaskParameter : ParameterOverride<LayerMask>
        {
            public override void Interp(LayerMask from, LayerMask to, float t)
            {
                value = t > 0 ? to : from;
            }
        }

        [System.Serializable]
        public sealed class MinMaxRangeParameter : ParameterOverride<MK.Glow.MinMaxRange>
        {
            public override void Interp(MK.Glow.MinMaxRange from, MK.Glow.MinMaxRange to, float t)
            {
                value.minValue = Mathf.Lerp(from.minValue, to.minValue, t);
                value.maxValue = Mathf.Lerp(from.maxValue, to.maxValue, t);
            }
        }

        #if UNITY_EDITOR
        public bool showEditorMainBehavior = true;
		public bool showEditorBloomBehavior;
		public bool showEditorLensSurfaceBehavior;
		public bool showEditorLensFlareBehavior;
		public bool showEditorGlareBehavior;
        /// <summary>
        /// Keep this value always untouched, editor internal only
        /// </summary>
        public bool isInitialized = false;
        #endif
        
        //Main
        public BoolParameter allowGeometryShaders = new BoolParameter() { value = true };
        public BoolParameter allowComputeShaders = new BoolParameter() { value = true };
        public DebugViewParameter debugView = new DebugViewParameter() { value = MK.Glow.DebugView.None };
        public QualityParameter quality = new QualityParameter() { value = MK.Glow.Quality.High };
        public WorkflowParameter workflow = new WorkflowParameter() { value = MK.Glow.Workflow.Luminance };
        public LayerMaskParameter selectiveRenderLayerMask = new LayerMaskParameter() { value = -1 };
        [Range(-1f, 1f)]
        public FloatParameter anamorphicRatio = new FloatParameter() { value = 0 };
        [Range(0f, 1f)]
		public FloatParameter lumaScale = new FloatParameter() { value = 0.5f };
        [Range(0f, 1f)]
		public FloatParameter blooming = new FloatParameter() { value = 0f };

        //Bloom
        [MK.Glow.MinMaxRange(0, 10)]
        public MinMaxRangeParameter bloomThreshold = new MinMaxRangeParameter() { value = new MinMaxRange(1.0f, 10f) };
        [Range(1f, 10f)]
		public FloatParameter bloomScattering = new FloatParameter() { value = 7f };
		public FloatParameter bloomIntensity = new FloatParameter() { value = 0f };

        //LensSurface
        public BoolParameter allowLensSurface = new BoolParameter() { overrideState = true, value = false };
		public Texture2DParameter lensSurfaceDirtTexture = new Texture2DParameter();
		public FloatParameter lensSurfaceDirtIntensity = new FloatParameter() { value = 0.0f };
		public Texture2DParameter lensSurfaceDiffractionTexture = new Texture2DParameter();
		public FloatParameter lensSurfaceDiffractionIntensity = new FloatParameter() { value = 0.0f };

        //LensFlare
        public BoolParameter allowLensFlare = new BoolParameter() { overrideState = true, value = false };
        [Range(0f, 25f)]
		public FloatParameter lensFlareGhostFade = new FloatParameter() { value = 10f };
		public FloatParameter lensFlareGhostIntensity = new FloatParameter() { value = 0.0f };
        [MK.Glow.MinMaxRange(0, 10)]
		public MinMaxRangeParameter lensFlareThreshold = new MinMaxRangeParameter() { value = new MinMaxRange(1.3f, 10f) };
        [Range(0f, 8f)]
		public FloatParameter lensFlareScattering = new FloatParameter() { value = 5f };
		public Texture2DParameter lensFlareColorRamp = new Texture2DParameter();
        [Range(-100f, 100f)]
		public FloatParameter lensFlareChromaticAberration = new FloatParameter() { value = 53f };
        [Range(0, 5)]
		public IntParameter lensFlareGhostCount = new IntParameter() { value = 3 };
        [Range(-1f, 1f)]
		public FloatParameter lensFlareGhostDispersal = new FloatParameter() { value = 0.6f };
        [Range(0f, 10f)]
		public FloatParameter lensFlareHaloFade = new FloatParameter() { value = 2f };
		public FloatParameter lensFlareHaloIntensity = new FloatParameter() { value = 0.0f };
        [Range(0f, 1f)]
		public FloatParameter lensFlareHaloSize = new FloatParameter() { value = 0.4f };

        //Glare
        public BoolParameter allowGlare = new BoolParameter() { overrideState = true, value = false };
        [Range(0.0f, 1.0f)]
        public FloatParameter glareBlend = new FloatParameter() { value = 0.33f };
        [MK.Glow.MinMaxRange(0, 10)]
        public MinMaxRangeParameter glareThreshold = new MinMaxRangeParameter() { value = new MinMaxRange(1.0f, 10f)};
        //Sample0
        [Range(0f, 10f)]
        public FloatParameter glareSample0Scattering = new FloatParameter() { value = 5.0f };
        [Range(0f, 360f)]
        public FloatParameter glareSample0Angle = new FloatParameter() { value = 0.0f };
        public FloatParameter glareSample0Intensity = new FloatParameter() { value = 0.0f };
        [Range(0f, 10f)]
        public FloatParameter glareSample0Offset = new FloatParameter() { value = 0.0f };
        //Sample1
        [Range(0f, 10f)]
        public FloatParameter glareSample1Scattering = new FloatParameter() { value = 5.0f };
        [Range(0f, 360f)]
        public FloatParameter glareSample1Angle = new FloatParameter() { value = 45.0f };
        public FloatParameter glareSample1Intensity = new FloatParameter() { value = 0.0f };
        [Range(0f, 10f)]
        public FloatParameter glareSample1Offset = new FloatParameter() { value = 0.0f };
        //Sample0
        [Range(0f, 10f)]
        public FloatParameter glareSample2Scattering = new FloatParameter() { value = 5.0f };
        [Range(0f, 360f)]
        public FloatParameter glareSample2Angle = new FloatParameter() { value = 90.0f };
        public FloatParameter glareSample2Intensity = new FloatParameter() { value = 0.0f };
        [Range(0f, 10f)]
        public FloatParameter glareSample2Offset = new FloatParameter() { value = 0.0f };
        //Sample0
        [Range(0f, 10f)]
        public FloatParameter glareSample3Scattering = new FloatParameter() { value = 5.0f };
        [Range(0f, 360f)]
        public FloatParameter glareSample3Angle = new FloatParameter() { value = 135.0f };
        public FloatParameter glareSample3Intensity = new FloatParameter() { value = 0.0f };
        [Range(0f, 10f)]
        public FloatParameter glareSample3Offset = new FloatParameter() { value = 0.0f };

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            if(workflow == Workflow.Selective && PipelineProperties.xrEnabled)
                return false;
            else
                return enabled.value;
        }
    }
    
    public sealed class MKGlowRenderer : PostProcessEffectRenderer<MKGlow>
    {
		private Effect effect = new Effect();
        private RenderTarget _source, _destination;

        public override void Init()
        {
            effect.Enable(RenderPipeline.SRP);
        }

        public override void Release()
        {
            effect.Disable();
        }

        public override void Render(PostProcessRenderContext context)
        {
            context.command.BeginSample(PipelineProperties.CommandBufferProperties.commandBufferName);
            _source.renderTargetIdentifier = context.source;
            _destination.renderTargetIdentifier = context.destination;
			effect.Build(_source, _destination, settings, context.command, context.camera);
            context.command.EndSample(PipelineProperties.CommandBufferProperties.commandBufferName);
        }
    }
}
#endif