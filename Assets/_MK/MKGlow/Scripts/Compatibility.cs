//////////////////////////////////////////////////////
// MK Glow Compatibility	    	    	       	//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace MK.Glow
{
    #if UNITY_2018_3_OR_NEWER
    using XRSettings = UnityEngine.XR.XRSettings;
    #endif
	public static class Compatibility
    {
        private static readonly bool _defaultHDRFormatSupported = SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.DefaultHDR);
        
        /// <summary>
        /// Returns true if the device and used API supports geometry shaders
        /// </summary>
        public static bool CheckGeometryShaderSupport()
        {
            bool supportedOnPlattform = false;
            switch(SystemInfo.graphicsDeviceType)
            {
                case GraphicsDeviceType.Vulkan:
                case GraphicsDeviceType.Direct3D11:
                case GraphicsDeviceType.Direct3D12:
                case GraphicsDeviceType.PlayStation4:
                case GraphicsDeviceType.OpenGLCore:
                #if UNITY_2017_3_OR_NEWER
                case GraphicsDeviceType.XboxOneD3D12:
                #endif
                case GraphicsDeviceType.XboxOne:
                    supportedOnPlattform = true;
                break;
                default:
                supportedOnPlattform = false;
                break;
            }

            return SystemInfo.graphicsShaderLevel >= 40 && supportedOnPlattform;
        }

        /// <summary>
        /// Returns true if the device and used API supports direct compute
        /// </summary>
        public static bool CheckComputeShaderSupport()
        {
            bool supportedOnPlattform = false;
            switch(SystemInfo.graphicsDeviceType)
            {
                case GraphicsDeviceType.Vulkan:
                case GraphicsDeviceType.Direct3D11:
                case GraphicsDeviceType.Direct3D12:
                case GraphicsDeviceType.PlayStation4:
                //Gles3 random writes is throwing the following issue
                //RenderTexture.Create failed: format unsupported for random writes - RGBA4 UNorm (9).
                //The issue should be officially fixed in late 2019
                //case GraphicsDeviceType.OpenGLES3:
                case GraphicsDeviceType.OpenGLCore:
                #if UNITY_2017_4_OR_NEWER
                case GraphicsDeviceType.Switch:
                #endif
                #if UNITY_2017_3_OR_NEWER
                case GraphicsDeviceType.XboxOneD3D12:
                #endif
                case GraphicsDeviceType.XboxOne:
                    supportedOnPlattform = true;
                break;
                default:
                supportedOnPlattform = false;
                break;
            }
            return SystemInfo.supportsComputeShaders && supportedOnPlattform && _defaultHDRFormatSupported;
        }

        /// <summary>
        /// Returns true if the device and used API supports lens flare
        /// </summary>
        /// <returns></returns>
        public static bool CheckLensFlareFeatureSupport()
        {
            bool supportedOnPlattform;
            switch(SystemInfo.graphicsDeviceType)
            {
                case GraphicsDeviceType.OpenGLCore:
                case GraphicsDeviceType.Vulkan:
                case GraphicsDeviceType.Direct3D11:
                case GraphicsDeviceType.Direct3D12:
                case GraphicsDeviceType.PlayStation4:
                case GraphicsDeviceType.OpenGLES3:
                case GraphicsDeviceType.Metal:
                #if UNITY_2017_4_OR_NEWER
                case GraphicsDeviceType.Switch:
                #endif
                #if UNITY_2017_3_OR_NEWER
                case GraphicsDeviceType.XboxOneD3D12:
                #endif
                case GraphicsDeviceType.XboxOne:
                    supportedOnPlattform = true;
                break;
                default:
                supportedOnPlattform = false;
                break;
            }

            return SystemInfo.graphicsShaderLevel >= 30 && SystemInfo.supportedRenderTargetCount >= 2 && supportedOnPlattform && !PipelineProperties.singlePassStereoInstancedEnabled;
        }

        /// <summary>
        /// Returns true if the device and used API support glare
        /// </summary>
        /// <returns></returns>
        public static bool CheckGlareFeatureSupport()
        {
            bool supportedOnPlattform;
            switch(SystemInfo.graphicsDeviceType)
            {
                case GraphicsDeviceType.OpenGLCore:
                case GraphicsDeviceType.Vulkan:
                case GraphicsDeviceType.Direct3D11:
                case GraphicsDeviceType.Direct3D12:
                case GraphicsDeviceType.PlayStation4:
                case GraphicsDeviceType.Metal:
                #if UNITY_2017_4_OR_NEWER
                case GraphicsDeviceType.Switch:
                #endif
                #if UNITY_2017_3_OR_NEWER
                case GraphicsDeviceType.XboxOneD3D12:
                #endif
                case GraphicsDeviceType.XboxOne:
                    supportedOnPlattform = true;
                break;
                default:
                supportedOnPlattform = false;
                break;
            }

            return SystemInfo.graphicsShaderLevel >= 40 && SystemInfo.supportedRenderTargetCount >= 6 && supportedOnPlattform && !PipelineProperties.singlePassStereoInstancedEnabled;
        }

        /// <summary>
        /// Returns the supported rendertexture format used for rendering
        /// </summary>
        /// <returns></returns>
        internal static RenderTextureFormat CheckSupportedRenderTextureFormat()
        {
            return _defaultHDRFormatSupported ? RenderTextureFormat.DefaultHDR : RenderTextureFormat.Default;
        }
    }
}