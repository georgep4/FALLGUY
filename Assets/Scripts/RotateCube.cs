using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateCube : MonoBehaviour {

   // public float spinForce;
    private float spinForce2;

	// Use this for initialization
	void Start () {

        spinForce2 = Random.Range(-80, 80);

        if (spinForce2 > -20 && spinForce2 < 20)
        {
            spinForce2 = Random.Range(20, 80);
        }

	}
	
	// Update is called once per frame
	void Update () {
        //   transform.Rotate(0, 0, spinForce * Time.deltaTime);
        transform.Rotate(0, 0, spinForce2 * Time.deltaTime);
    }

    public void ChangeSpin()
    {
       // spinForce = -spinForce;
        spinForce2 = -spinForce2;
    }



}
