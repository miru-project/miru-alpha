package com.example.miru_new

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import binary.AndroidLib

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.miru_new/miru_core"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "InitAAR" -> {
                    try {
                        val configPath = call.arguments as String
                        val androidLib = AndroidLib()
                        androidLib.initAAR(configPath)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", "Failed to initialize miru-core: ${e.message}", e.stackTraceToString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}