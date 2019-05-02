using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GoogleMobileAds.Api;

public class AdMobManager : MonoBehaviour
{

    private BannerView bannerView;

    [SerializeField] private string appID = "";

    [SerializeField] private string bannerID = "";
    [SerializeField] private string regularAD = "";


    private void Awake()
    {
           MobileAds.Initialize(appID);

    }

    public void RequestRegularAD()
    {
        Debug.Log("RequestRegularAD()");
           InterstitialAd AD = new InterstitialAd(regularAD);
           AdRequest request = new AdRequest.Builder().Build();
           AD.LoadAd(request);
    }

    public void RequestBanner()
    {
        Debug.Log("RequestBanner()");
           bannerView = new BannerView(bannerID, AdSize.Banner, AdPosition.Center);
           AdRequest request = new AdRequest.Builder().Build();
           bannerView.LoadAd(request);

    }

    //////////////////////// Previous ////////////
    /*
        private BannerView bannerView;

        [SerializeField] private string appID = "";  ca-app-pub-2625071124190654~9086478061

        [SerializeField] private string bannerID = "";  ca-app-pub-2625071124190654/2431593897
        [SerializeField] private string regularAD = "";  ca-app-pub-2625071124190654/9160653778


        private void Awake()
        {
               MobileAds.Initialize(appID);

        }

        public void RequestRegularAD()
        {
            Debug.Log("RequestRegularAD()");
               InterstitialAd AD = new InterstitialAd(regularAD);
               AdRequest request = new AdRequest.Builder().Build();
               AD.LoadAd(request);
        }

        public void RequestBanner()
        {
            Debug.Log("RequestBanner()");
               bannerView = new BannerView(bannerID, AdSize.Banner, AdPosition.Center);
               AdRequest request = new AdRequest.Builder().Build();
               bannerView.LoadAd(request);

        }
    */

}
