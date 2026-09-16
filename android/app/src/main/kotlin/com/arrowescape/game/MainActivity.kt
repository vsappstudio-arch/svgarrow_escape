package com.arrowescape.game

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ARROWW's UI is unconditionally dark and already asks for a
        // transparent, edge-to-edge system navigation bar via
        // SystemChrome (see main.dart). On API 29+, Android separately
        // draws its own translucent contrast scrim OVER a transparent
        // navigation bar by default - regardless of the requested
        // color - to guarantee the gesture pill stays legible against
        // arbitrary app content. That scrim is what was showing as a
        // white strip: SystemChrome's systemNavigationBarColor has no
        // native counterpart for disabling it, and on targetSdk 35+,
        // Window.setNavigationBarColor/setStatusBarColor (what
        // SystemChrome's color properties call into) are deprecated
        // no-ops, so no Dart-level API can reach this. Disabling
        // enforcement here is the correct, non-deprecated way to let
        // ARROWW's own dark background show through instead - the
        // gesture pill itself stays visible via the light icon
        // appearance SystemChrome already requests.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
            window.isStatusBarContrastEnforced = false
        }
    }
}
