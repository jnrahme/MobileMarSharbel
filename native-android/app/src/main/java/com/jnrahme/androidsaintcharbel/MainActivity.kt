package com.jnrahme.androidsaintcharbel

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.jnrahme.androidsaintcharbel.app.SaintCharbelAndroidApp
import com.jnrahme.androidsaintcharbel.core.theme.SaintCharbelTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SaintCharbelTheme {
                SaintCharbelAndroidApp()
            }
        }
    }
}

