using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Teleportation : MonoBehaviour
{
    public Transform teleportTarget;
    public GameObject thePlayer;
    public float velocity { get; internal set; }
    public Rigidbody rb;

    LevelManager letsRestart;

    void Start()
    {
        Debug.Log("Teleportation");
        rb = GetComponent<Rigidbody>();
    }

    void OnTriggerEnter(Collider other)
    {
        Debug.Log("Teleportation:  Restart Level");
        letsRestart = FindObjectOfType<LevelManager>();
        letsRestart.RestartLevel();
        print(gameObject.name);

        // thePlayer.transform.position = teleportTarget.transform.position;
        //  rb.velocity = Vector3.zero;
    }

}
