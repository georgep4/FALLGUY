using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadHit : MonoBehaviour
{
    public GameObject explosionEffect;
    public AudioSource source;
    public AudioClip explodeblock;

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Blocks")
        {
            source.PlayOneShot(explodeblock);
            GameObject impactGo = Instantiate(explosionEffect, transform.position, transform.rotation);
            Destroy(impactGo, 2f);
        }
    }
}
