package com.example.vishnu_training_and_placements
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val CHANNEL = "dev_options_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "isDevOptionsEnabled") {
                try {
                    val isEnabled = Settings.Global.getInt(
                        contentResolver,
                        Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                        0
                    ) == 1
                    result.success(isEnabled)
                } catch (e: Exception) {
                    result.error("ERROR", "Could not check Developer Options", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
