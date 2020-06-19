package com.yqb.flutterdemo

import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.SplashScreen
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var methodChannel: MethodChannel? = null

    override fun provideSplashScreen(): SplashScreen? {
        return CustomSplashScreen()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mu.demo")
        methodChannel?.setMethodCallHandler { c, r ->
            if (c.method == "toast") {
                Toast.makeText(this, c.argument("message") as? String ?: "toast", Toast.LENGTH_SHORT).show()
                r.success(null)
            } else {
                r.notImplemented()
            }
        }
    }

    override fun onBackPressed() {
        Log.i(Companion.TAG, "MainActivity#onBackPressed()")
        methodChannel?.invokeMethod("onBackPressed", null, object : MethodChannel.Result {
            override fun notImplemented() {
                Log.i(Companion.TAG, "MethodChannel.Result: notImplemented")
                super@MainActivity.onBackPressed()
            }

            override fun error(p0: String?, p1: String?, p2: Any?) {
                Log.i(Companion.TAG, "MethodChannel.Result: error($p0, $p1, $p2)")
                super@MainActivity.onBackPressed()
            }

            override fun success(p0: Any?) {
                Log.i(Companion.TAG, "MethodChannel.Result: success($p0)")
                if (p0 != true) {
                    super@MainActivity.onBackPressed()
                }
            }
        })
    }

    companion object {
        private const val TAG = "MainActivity"
    }
}
