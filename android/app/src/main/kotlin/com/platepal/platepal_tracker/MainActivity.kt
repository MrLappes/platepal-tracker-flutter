package com.platepal.platepaltracker

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun getInitialRoute(): String? =
        when (intent?.action) {
            "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE",
            "android.intent.action.VIEW_PERMISSION_USAGE" -> "/privacy"
            else -> super.getInitialRoute()
        }
}
