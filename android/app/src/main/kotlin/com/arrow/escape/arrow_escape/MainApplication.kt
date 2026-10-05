package com.arrow.escape.arrow_escape

import android.app.Application
import com.google.android.gms.games.PlayGamesSdk

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Required by Play Games Services v2 before any Games API call.
        PlayGamesSdk.initialize(this)
    }
}
