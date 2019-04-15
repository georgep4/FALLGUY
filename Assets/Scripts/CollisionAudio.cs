using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollisionAudio : MonoBehaviour
{

    public AudioSource source;
    public AudioClip CollisionAudioSource;

    void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag == "Blocks")
        {
            source.PlayOneShot(CollisionAudioSource);
        }
    }

}
