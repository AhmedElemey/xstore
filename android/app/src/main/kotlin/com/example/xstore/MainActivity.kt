package com.xstore.app

import android.content.Intent
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // image_picker only adds a lens hint when the front camera is requested,
    // so the system camera opens on whichever lens it used last (often the
    // selfie camera). Ask for the back camera unless front was requested.
    override fun startActivityForResult(intent: Intent, requestCode: Int, options: Bundle?) {
        if (intent.action == MediaStore.ACTION_IMAGE_CAPTURE &&
            !intent.hasExtra(EXTRA_USE_FRONT_CAMERA) &&
            !intent.hasExtra(EXTRA_CAMERA_FACING)
        ) {
            intent.putExtra(EXTRA_CAMERA_FACING, 0) // legacy CAMERA_FACING_BACK
            intent.putExtra("android.intent.extras.LENS_FACING_BACK", 1)
            intent.putExtra(EXTRA_USE_FRONT_CAMERA, false)
        }
        super.startActivityForResult(intent, requestCode, options)
    }

    private companion object {
        const val EXTRA_CAMERA_FACING = "android.intent.extras.CAMERA_FACING"
        const val EXTRA_USE_FRONT_CAMERA = "android.intent.extra.USE_FRONT_CAMERA"
    }
}
