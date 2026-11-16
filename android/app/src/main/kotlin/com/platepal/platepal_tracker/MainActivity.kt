package com.platepal.platepaltracker

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15 enforces edge-to-edge for apps targeting SDK 35. Enabling it
        // explicitly keeps the same layout on older Android versions instead of
        // letting content jump when the device is upgraded.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

    override fun getInitialRoute(): String? =
        when (intent?.action) {
            "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE",
            "android.intent.action.VIEW_PERMISSION_USAGE" -> "/privacy"
            else -> super.getInitialRoute()
        }
}
