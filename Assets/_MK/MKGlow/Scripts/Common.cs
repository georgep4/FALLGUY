//////////////////////////////////////////////////////
// MK Glow Common       	    	    	       	//
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
namespace MK.Glow
{
    /// <summary>
    /// Type of the glow, selective requires seperate shaders
    /// </summary>
    public enum Workflow
    {
        Luminance = 0,
        Selective = 1
    }

    /// <summary>
    /// Glow _settings.quality profile forrendering
    /// </summary>
    public enum Quality
    {
        Ultra = 1,
        High = 2,
        Medium = 4,

        //Mobile quality for now disabled
        //On mobile quality glare feature cant work perfectly
        //postprocessing stack performs super slow so its quite hard to deal with it on mobile
        //focusing on legacy pipeline also seems not to be a good a idea
        //Mobile = 8
    }

    /// <summary>
    /// Debugging, Raw = Glowmap, default = pre ready, composite = Finalglow without Source image
    /// </summary>
    public enum DebugView
    {
        None = 0,
        RawBloom = 1,
        RawLensFlare = 2,
        RawGlare = 3,
        Bloom = 4,
        LensFlare = 5,
        Glare = 6,
        Composite = 7,
    }

    /// <summary>
    /// Dimension struct for representing render context size
    /// </summary>
    internal struct RenderDimension : IDimension
    {
        public RenderDimension(int width, int height)
        {
            this.width = width;
            this.height = height;
        }

        public int width { get; set; }
        public int height { get; set; }
        public RenderDimension renderDimension { get{ return this; } }
    }
    
    /// <summary>
    /// Defines which renderpipeline is used
    /// </summary>
    internal enum RenderPipeline
    {
        Legacy = 0,
        SRP = 1
    }
}
