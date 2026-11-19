package miru.alpha

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/// Hosts the in-app update hand-off: the Flutter side downloads the APK, this
/// side hands it to the system package installer through a content:// URI.
///
/// Android 7+ forbids file:// intents between apps, hence the FileProvider
/// (`res/xml/file_paths.xml`, declared in AndroidManifest.xml). Android 8+
/// additionally needs REQUEST_INSTALL_PACKAGES so the installer prompt can
/// appear at all.
class MainActivity : FlutterActivity() {
    private val updateChannel = "miru.alpha/update"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, updateChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "installApk" -> {
                        val path = call.argument<String>("path")
                        if (path.isNullOrBlank()) {
                            result.error("NO_PATH", "installApk requires a path", null)
                        } else {
                            try {
                                installApk(path)
                                result.success(true)
                            } catch (error: Exception) {
                                result.error("INSTALL_FAILED", error.message, null)
                            }
                        }
                    }
                    "getSupportedAbis" -> {
                        try {
                            result.success(supportedAbis())
                        } catch (error: Exception) {
                            result.error("ABI_UNAVAILABLE", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun installApk(path: String) {
        val file = File(path)
        if (!file.exists()) error("APK not found: $path")

        val uri: Uri = FileProvider.getUriForFile(
            this,
            "$packageName.fileprovider",
            file,
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(intent)
    }

    /**
     * The ABIs this build can run, most preferred first.
     *
     * Dart cannot ask Android which ABIs it supports, and the update feed
     * carries one APK per ABI — choosing one by name needs this list, or a
     * device is handed an APK it cannot install
     * (INSTALL_FAILED_NO_MATCHING_ABIS).
     */
    private fun supportedAbis(): List<String> =
        android.os.Build.SUPPORTED_ABIS.toList()
}