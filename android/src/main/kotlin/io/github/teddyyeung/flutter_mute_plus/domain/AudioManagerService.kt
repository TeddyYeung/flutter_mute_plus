package io.github.teddyyeung.flutter_mute_plus.domain

import io.github.teddyyeung.flutter_mute_plus.entities.RingerMode

interface AudioManagerService {

    fun getCurrentRingerMode(): RingerMode?
    fun setRingerMode(ringerMode: RingerMode)

}