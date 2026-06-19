package com.musicplayer.music_player

import android.app.Service
import android.content.Intent
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.IBinder
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MechanicalLightBridge : Service() {

    companion object {
        private const val TAG = "MechanicalLightBridge"
        private const val CHANNEL = "mechanical_light_bridge"
    }

    private var mediaSession: MediaSession? = null
    private var channel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        mediaSession = MediaSession(this, "MusicPlayer")
        mediaSession?.setFlags(3)
        mediaSession?.isActive = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "UPDATE_STATE" -> {
                val playing = intent.getBooleanExtra("playing", false)
                val title = intent.getStringExtra("title") ?: ""
                val artist = intent.getStringExtra("artist") ?: ""
                val album = intent.getStringExtra("album") ?: ""

                val state = PlaybackState.Builder()
                    .setState(
                        if (playing) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED,
                        0L,
                        1.0f
                    )
                    .setActions(823L)
                    .build()
                mediaSession?.setPlaybackState(state)

                val metadata = android.media.MediaMetadata.Builder()
                    .putString(android.media.MediaMetadata.METADATA_KEY_TITLE, title)
                    .putString(android.media.MediaMetadata.METADATA_KEY_ARTIST, artist)
                    .putString(android.media.MediaMetadata.METADATA_KEY_ALBUM, album)
                    .build()
                mediaSession?.setMetadata(metadata)
                mediaSession?.isActive = true
            }
            "STOP" -> {
                mediaSession?.isActive = false
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        mediaSession?.release()
        mediaSession = null
        super.onDestroy()
    }
}
