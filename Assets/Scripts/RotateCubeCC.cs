using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateCubeCC : MonoBehaviour {

    // public float spinForce;
    private float spinForce3;
    float timeLeft2 = 30f;

    // Use this for initialization
    void Start()
    {
        setRandomValues2();


    }

    // Update is called once per frame
    void Update()
    {
        //   transform.Rotate(0, 0, spinForce * Time.deltaTime);
        transform.Rotate(0, 0, spinForce3 * Time.deltaTime);
        timeLeft2 -= Time.deltaTime;

        if (timeLeft2 < 0)
        {
            setRandomValues2();
        }
    }

    public void ChangeSpin()
    {
        // spinForce = -spinForce;
        spinForce3 = -spinForce3;
    }

    public void setRandomValues2()
    {
        timeLeft2 = 30f;
        spinForce3 = Random.Range(-150, 150);

        if (spinForce3 > -20 && spinForce3 < 20)
        {
            spinForce3 = Random.Range(20, 150);
        }

    }

}
