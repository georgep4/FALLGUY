using UnityEngine;

public class bulletBall4 : MonoBehaviour
{
    private Animator isFlying;
    
    // public float delay = .3f;
    public float speed = 10f;  //cj 20f
   // public float force = 700f;
   // public float radius = 5f;
    public Rigidbody rb;

    //float countdown;
 //   bool hasExploded = false;

    public GameObject explosionEffect;

    // Start is called before the first frame update
    void Start()
    {
        isFlying = GetComponent<Animator>();
        //countdown = delay;
        rb.velocity = transform.forward * speed;
    }

    private void OnCollisionEnter(Collider col)
    {
        if (col.tag.Equals("Block"))
        {
            //Destroy(gameObject);
            // GameObject impactGo = Instantiate(explosionEffect, transform.position, transform.rotation);
            //  Destroy(impactGo, 5f);
            isFlying.enabled = false;

        }

    }
    
}
