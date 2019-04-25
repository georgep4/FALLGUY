using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateCube : MonoBehaviour {

   // public float spinForce;
    private float spinForce2;
    float timeLeft = 30f;

	// Use this for initialization
	void Start () {

        setRandomValues();

	}
	
	// Update is called once per frame
	void Update () {
        //   transform.Rotate(0, 0, spinForce * Time.deltaTime);
        transform.Rotate(0, 0, spinForce2 * Time.deltaTime);
        timeLeft -= Time.deltaTime;

        if (timeLeft < 0)
        {
            setRandomValues();
        }
    }

    public void ChangeSpin()
    {
       // spinForce = -spinForce;
        spinForce2 = -spinForce2;
    }

    public void setRandomValues()
    {
        timeLeft = 30f;
        spinForce2 = Random.Range(-150, 150);

        if (spinForce2 > -20 && spinForce2 < 20)
        {
            spinForce2 = Random.Range(20, 150);
        }

    }

}
