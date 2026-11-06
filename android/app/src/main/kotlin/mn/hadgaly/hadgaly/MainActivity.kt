package mn.hadgaly.hadgaly

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private data class Transfer(val file: File, val saving: Boolean, val result: MethodChannel.Result)
    private var transfer: Transfer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hadgaly/backup_files")
            .setMethodCallHandler { call, result ->
                if (call.method == "closeForRestore") {
                    result.success(null)
                    finishAndRemoveTask()
                    return@setMethodCallHandler
                }
                val saving = call.method == "save"
                if (!saving && call.method != "open") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (transfer != null) {
                    result.error("BUSY", null, null)
                    return@setMethodCallHandler
                }
                try {
                    val file = File(call.arguments as String).canonicalFile
                    val folder = requireNotNull(file.parentFile)
                    require(folder.parentFile == cacheDir.canonicalFile &&
                        folder.name.startsWith("hadgaly-backup-") && file.name == "transfer.hadgaly")
                    val intent = Intent(if (saving) Intent.ACTION_CREATE_DOCUMENT else Intent.ACTION_OPEN_DOCUMENT)
                        .addCategory(Intent.CATEGORY_OPENABLE)
                        .setType(if (saving) "application/octet-stream" else "*/*")
                    if (saving) intent.putExtra(Intent.EXTRA_TITLE, "Hadgaly.hadgaly")
                    transfer = Transfer(file, saving, result)
                    startActivityForResult(intent, PICK_BACKUP)
                } catch (_: Exception) {
                    transfer = null
                    result.error("PICKER_FAILED", null, null)
                }
            }
    }

    @Deprecated("Android activity result callback used by FlutterActivity")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_BACKUP) return
        val job = transfer ?: return
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            transfer = null
            job.result.success(false)
            return
        }
        Thread {
            val success = try {
                if (job.saving) {
                    job.file.inputStream().use { input ->
                        requireNotNull(contentResolver.openOutputStream(uri, "wt")).use { output ->
                            copyBounded(input, output)
                        }
                    }
                } else {
                    requireNotNull(contentResolver.openInputStream(uri)).use { input ->
                        job.file.outputStream().use { output -> copyBounded(input, output) }
                    }
                }
                true
            } catch (_: Exception) {
                false
            }
            runOnUiThread {
                transfer = null
                if (success) job.result.success(true) else job.result.error("TRANSFER_FAILED", null, null)
            }
        }.start()
    }

    private fun copyBounded(input: InputStream, output: OutputStream) {
        val buffer = ByteArray(64 * 1024)
        var total = 0L
        while (true) {
            val count = input.read(buffer)
            if (count < 0) break
            total += count
            require(total <= 64L * 1024 * 1024 + 40)
            output.write(buffer, 0, count)
        }
    }

    companion object {
        private const val PICK_BACKUP = 7061
    }
}
