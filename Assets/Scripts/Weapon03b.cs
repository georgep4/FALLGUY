using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Weapon03b : MonoBehaviour
{
    public Transform firePoint;
    public GameObject bulletPrefab;
    Vector3 targetPosition;

    void Start()
    {
        Debug.Log("Weapon03b");

    }

    //    Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Fire1"))
        {
            Shoot();
        }

    }

    void Shoot()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, 1000))
        {
            targetPosition = hit.point;
         //   this.transform.LookAt(targetPosition);
         //   Debug.Log(hit);

            Instantiate(bulletPrefab, firePoint.position, Quaternion.LookRotation(ray.direction));

        }


        // shooting logic
        // Instantiate(bulletPrefab, firePoint.position, firePoint.rotation);


    }

}
