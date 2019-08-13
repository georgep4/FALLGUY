
using GoogleMobileAds.Api;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AdMobManager2 : MonoBehaviour
{
    public string appId = "ca-app-pub-2625071124190654~9086478061";
    private BannerView bannerView;

    public void Start()
    { 
        MobileAds.Initialize(appId);
        RequestBanner();
        RequestInterstitial();
    }

    public void RequestBanner()
    {
#if UNITY_ANDROID
        string adUnitId = "ca-app-pub-2625071124190654/2431593897";  //  Pit Falling = ca-app-pub-2625071124190654/2431593897,  Orig = ca-app-pub-3940256099942544/6300978111
#elif UNITY_IPHONE
            string adUnitId = "ca-app-pub-3940256099942544/2934735716";
#else
            string adUnitId = "unexpected_platform";
#endif

        // Create a 320x50 banner at the top of the screen.
        bannerView = new BannerView(adUnitId, AdSize.Banner, AdPosition.Top);

        // Create an empty ad request.
        AdRequest request = new AdRequest.Builder().Build();

        // Load the banner with the request.
        bannerView.LoadAd(request);
    }

    private InterstitialAd interstitial;

    public void RequestInterstitial()
    {
#if UNITY_ANDROID
        string adUnitId = "ca-app-pub-2625071124190654/9160653778";  //  Pit Falling = ca-app-pub-2625071124190654/9160653778,  Orig = ca-app-pub-3940256099942544/1033173712
#elif UNITY_IPHONE
        string adUnitId = "ca-app-pub-3940256099942544/4411468910";
#else
        string adUnitId = "unexpected_platform";
#endif

        // Initialize an InterstitialAd.
        this.interstitial = new InterstitialAd(adUnitId);

        // Create an empty ad request.
        AdRequest request = new AdRequest.Builder().Build();
        // Load the interstitial with the request.
        this.interstitial.LoadAd(request);
    }

    public void ShowInterstitial()
    {

        if (this.interstitial.IsLoaded())
        {
            this.interstitial.Show();

        }
    }
}
