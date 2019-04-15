using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bomb : MonoBehaviour
{
   // public float delay = 1f;
    public float force = 700f;
    public float radius = 5f;
    public Rigidbody rb;
    //public AudioSource source;
    //public AudioClip explodeGlowblock;

    // float countdown;
    bool hasExploded = false;

    //public GameObject explosionEffect;

    private void Start()
    {
        Debug.Log("Bomb");

    }

    void OnCollisionEnter (Collision col)
    {
        if(col.gameObject.tag == "Player")
        {
            Explode();
            hasExploded = true;
        }
    }



        void Explode()
        {
       // source.PlayOneShot(explodeGlowblock);
        //Show effect
       // GameObject impactGo = Instantiate(explosionEffect, transform.position, transform.rotation);
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

    }
}