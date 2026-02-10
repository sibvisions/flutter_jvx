package com.sibvisions.flutter_jvx

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.sibvisions.flutter_jvx/security"
    private var secureCount: Int = 0
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).
          setMethodCallHandler { call, result ->
            when (call.method) {
                "setAuthStatus" -> {
                    val enable = call.arguments as Boolean

                    result.success(false)
                }

                "hideBlur" -> {
                    result.success(false)
                }

                "setSecure" -> {
                    val secure = call.arguments as Boolean

                    if (secure) {
                        secureCount++
                    }
                    else {
                        secureCount--
                        if (secureCount < 0) secureCount = 0
                    }

                    when (secureCount) {
                        0 -> window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        1 -> window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }

                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

}
