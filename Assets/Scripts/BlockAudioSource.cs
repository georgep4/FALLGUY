using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlockAudioSource : MonoBehaviour
{
    public AudioSource hitBlockHit;



    // Start is called before the first frame update
    void Start()
    {
        hitBlockHit = GetComponent<AudioSource>();
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag=="Player")
        {
            hitBlockHit.Play();
        }
    }
}
