package com.musicplayer.music_player

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "music_broadcast")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "broadcastMetadata" -> {
                        val title = call.argument<String>("title")
                        val artist = call.argument<String>("artist")
                        val album = call.argument<String>("album")
                        val playing = call.argument<Boolean>("playing") ?: false
                        broadcastMusicMetadata(title, artist, album, playing)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun broadcastMusicMetadata(title: String?, artist: String?, album: String?, playing: Boolean) {
        val intent = Intent("com.android.music.metachanged").apply {
            putExtra("track", title ?: "")
            putExtra("artist", artist ?: "")
            putExtra("album", album ?: "")
            putExtra("playing", playing)
            putExtra("package_name", packageName)
            putExtra("package", packageName)
            `package` = packageName
        }
        sendBroadcast(intent)

        val playIntent = Intent("com.android.music.playstatechanged").apply {
            putExtra("playing", playing)
            putExtra("track", title ?: "")
            putExtra("artist", artist ?: "")
            `package` = packageName
        }
        sendBroadcast(playIntent)
    }
}
