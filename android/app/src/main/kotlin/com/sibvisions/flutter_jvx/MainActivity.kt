package com.sibvisions.flutter_jvx

import android.os.Build
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Handle the splash screen transition.
            val splashScreen = installSplashScreen()
        }
        super.onCreate(savedInstanceState)
    }
}
