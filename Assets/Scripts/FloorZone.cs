using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloorZone : MonoBehaviour
{

    public GameObject RestartButton;

    private void OnTriggerEnter(Collider collision)
    {
        if (collision.tag.Equals("Player"))
        {
            RestartButton.SetActive(true);
        }

    }
}
