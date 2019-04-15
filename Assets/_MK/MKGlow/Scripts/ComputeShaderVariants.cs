//////////////////////////////////////////////////////
// MK Glow Compute Shader Variants	    		    //
//					                                //
// Created by Michael Kremmel                       //
// www.michaelkremmel.de | www.michaelkremmel.store //
// Copyright © 2019 All rights reserved.            //
//////////////////////////////////////////////////////
using System.Collections.Generic;

namespace MK.Glow
{
    /////////////////////////////////////////////////////////////////////////////////////////////
    // Compute shader variants
    /////////////////////////////////////////////////////////////////////////////////////////////
    //
    //4x16 feature matrix currently not used, uncommend if it comes back any time... 
    //
    internal sealed class ComputeShaderVariants
    {
        /*
        internal struct Feature4x1
        {
            internal bool x, y, z, w;
            internal Feature4x1(bool x, bool y, bool z, bool w)
            {
                this.x = x;
                this.y = y;
                this.z = z;
                this.w = w;
            }
        }
        */
        internal struct Feature3x1
        {
            internal bool x, y, z;
            internal Feature3x1(bool x, bool y, bool z)
            {
                this.x = x;
                this.y = y;
                this.z = z;
            }

            /*
            public static explicit operator Feature4x1(Feature3x1 feature3x1)
            {
                return new Feature4x1()
                {
                    x = feature3x1.x,
                    y = feature3x1.y,
                    z = feature3x1.z,
                    w = false
                };
            }
            */
        }
        
        /// <summary>
        /// Custom implementation of variants for compute shaders, features need to be set as defined in the feature matrix
        /// Maximum up to 8 variants
        /// </summary>
        internal class Variants3x8
        {
            internal Variants3x8(int startIndex)
            {   
                this.startIndex = startIndex;
            }

            internal int StartIndex
            {
                get{ return startIndex; }
            }

            private Dictionary<Feature3x1, int> variants;
            private int startIndex;

            //To prevent the program from gc use a if else instead of a dictionary
            //Dicitonary implementation is commented out for now
            public void GetVariantNumber(Feature3x1 enabledFeatures, out int kernelNumber)
            {
                if(enabledFeatures.x)
                {
                    if(enabledFeatures.y)
                    {
                        if(enabledFeatures.z)
                        {
                            kernelNumber = startIndex + 5;
                        }
                        else
                        {
                            kernelNumber = startIndex + 3;
                        }
                    }
                    else
                    {
                        if(enabledFeatures.z)
                        {
                            kernelNumber = startIndex + 7;
                        }
                        else
                        {
                            kernelNumber = startIndex + 1;
                        }
                    }
                }
                else if(enabledFeatures.y)
                {
                    if(enabledFeatures.z)
                    {
                        kernelNumber = startIndex + 6;
                    }
                    else
                    {
                        kernelNumber = startIndex + 2;
                    }
                }
                else if(enabledFeatures.z)
                {
                    kernelNumber = startIndex + 4;
                }
                else
                {
                    kernelNumber = startIndex;
                }
            }
        }

        /*
        /// <summary>
        /// Custom implementation of variants for compute shaders, features need to be set as defined in the feature matrix
        /// Maximum up to 16 variants
        /// </summary>
        internal class Variants4x16
        {
            internal Variants4x16(int startIndex)
            {
                this._startIndex = startIndex;

                //build variants
                variants = new Dictionary<Feature4x1, int>();
                variants.Add(new Feature4x1(false, false, false, false), startIndex + 0);
                variants.Add(new Feature4x1(true, false, false, false), startIndex + 1);
                variants.Add(new Feature4x1(false, true, false, false), startIndex + 2);
                variants.Add(new Feature4x1(true, true, false, false), startIndex + 3);
                variants.Add(new Feature4x1(false, false, true, false), startIndex + 4);
                variants.Add(new Feature4x1(true, true, true, false), startIndex + 5);
                variants.Add(new Feature4x1(false, true, true, false), startIndex + 6);
                variants.Add(new Feature4x1(true, false, true, false), startIndex + 7);
                variants.Add(new Feature4x1(false, true, false, true), startIndex + 8);
                variants.Add(new Feature4x1(false, false, false, true), startIndex + 9);
                variants.Add(new Feature4x1(false, false, true, true), startIndex + 10);
                variants.Add(new Feature4x1(false, true, true, true), startIndex + 11);
                variants.Add(new Feature4x1(true, true, false, true), startIndex + 12);
                variants.Add(new Feature4x1(true, true, true, true), startIndex + 13);
                variants.Add(new Feature4x1(true, false, true, true), startIndex + 14);
                variants.Add(new Feature4x1(true, false, false, true), startIndex + 15);
            }

            internal int StartIndex
            {
                get{ return _startIndex; }
            }

            private Dictionary<Feature4x1, int> variants;
            private int _startIndex;

            internal void GetVariantNumber(Feature4x1 enabledFeatures, out int kernelNumber)
            {
                variants.TryGetValue(enabledFeatures, out kernelNumber);
            }
        }
        */
    }
}