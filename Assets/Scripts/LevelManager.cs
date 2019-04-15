using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using UnityEngine.UI;

public class LevelManager : MonoBehaviour
{
    // private static LevelManager instance;
    // public static LevelManager Instance { get { return instance; } }

    //  public GameObject pauseMenu;
    //  public GameObject endMenu;
    //  public Text endTimerText;
    //  public Text timerText;

    //  private float startTime;
    //  private float levelDuration;
    //  public float silverTime;
    //  public float goldTime;

    // private float finalEndTime;

    public GameObject RestartButton;

  
    public void RestartLevel()
    {
        Time.timeScale = 1;
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    
    

}
