using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExplosiveForce : MonoBehaviour
{
    // public float delay = 1f;
    public float force = 700f;
    public float radius = 5f;
    public Rigidbody rb;
   // public AudioSource source;
    //public AudioClip BounceExplosiveForceAudio;

    // float countdown;
    bool hasExploded = false;

    public GameObject explosionEffect;

    private void Start()
    {
       // Debug.Log("Bomb");

    }

    void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag == "Blocks")
        {
            Explode();
            hasExploded = true;
        }
    }



    void Explode()
    {
       // source.PlayOneShot(BounceExplosiveForceAudio);
        //Show effect
        //GameObject impactGo = Instantiate(explosionEffect, transform.position, transform.rotation);
       // Destroy(impactGo, 2f);

        Collider[] colliders = Physics.OverlapSphere(transform.position, radius);

        foreach (Collider nearbyObject in colliders)
        {
            // add force
            Rigidbody rb = nearbyObject.GetComponent<Rigidbody>();
            if (rb != null)
            {
                rb.AddExplosionForce(force, transform.position, radius);
            }

            // Damage
        }
        //Destroy(gameObject);
       // ScoreCounter.scoreAmount += 500;
    }
}
