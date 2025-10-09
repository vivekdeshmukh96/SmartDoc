package com.example.collegeapplication

import io.flutter.embedding.android.FlutterActivity
import vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ImageCropperPlugin())
    }
}
