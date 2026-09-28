package io.github.teddyyeung.flutter_mute_plus.data


import android.media.AudioManager
import io.github.teddyyeung.flutter_mute_plus.domain.AudioManagerService
import io.github.teddyyeung.flutter_mute_plus.entities.RingerMode

class AudioManagerServiceImpl(private val audioManager: AudioManager) : AudioManagerService {

    override fun getCurrentRingerMode(): RingerMode? {
        return when (audioManager.ringerMode) {
            AudioManager.RINGER_MODE_NORMAL -> RingerMode.NORMAL
            AudioManager.RINGER_MODE_SILENT -> RingerMode.SILENT
            AudioManager.RINGER_MODE_VIBRATE -> RingerMode.VIBRATE
            else -> null
        }
    }

    override fun setRingerMode(ringerMode: RingerMode) {
        audioManager.ringerMode = when (ringerMode) {
            RingerMode.NORMAL -> AudioManager.RINGER_MODE_NORMAL
            RingerMode.SILENT -> AudioManager.RINGER_MODE_SILENT
            RingerMode.VIBRATE -> AudioManager.RINGER_MODE_VIBRATE
        }
    }
}
