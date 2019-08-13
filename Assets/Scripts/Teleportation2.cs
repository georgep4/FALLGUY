using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Teleportation2 : MonoBehaviour
{
   // public Transform teleportTarget;
   // public GameObject thePlayer;
   // public float velocity { get; internal set; }
  //  public Rigidbody rb;

    LevelManager letsRestart2;
    AdMobManager2 getIntertitial;
    AdMobManager2 getBanner;

    void Start()
    {
        Debug.Log("Teleportation2");

        getBanner = FindObjectOfType<AdMobManager2>();
        getBanner.RequestBanner();
        getIntertitial.RequestInterstitial(); // new
    }

    void OnTriggerEnter(Collider other)
    {

        if (other.gameObject.tag == "TeleFromHere") { 

            Debug.Log("Teleportation2:  Restart Level");

            getIntertitial = FindObjectOfType<AdMobManager2>();
           //  getIntertitial.RequestInterstitial();  // ORIG was commented out.
            getIntertitial.ShowInterstitial();

            letsRestart2 = FindObjectOfType<LevelManager>();
            letsRestart2.RestartLevel();
            print(gameObject.name);

        }
        // thePlayer.transform.position = teleportTarget.transform.position;
        //  rb.velocity = Vector3.zero;
    }

}
