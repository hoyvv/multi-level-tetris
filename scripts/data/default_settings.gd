extends RefCounted
class_name DefaultSettings

const SETTINGS: Dictionary = {
    "Video": {
        "screen_mode": DisplayServer.WINDOW_MODE_FULLSCREEN,
        "borderless": false,
        "vsync": DisplayServer.VSYNC_DISABLED
    },

    "Audio": {
        "master_volume": 1.0,
        # "sfx_volume": 1.0,
        # "music_volume": 1.0
    }	
}

const VSYNC_MODE: Dictionary[String, int] = {
    "Enabled": DisplayServer.VSYNC_ENABLED,
    "Disabled": DisplayServer.VSYNC_DISABLED,
    "Adaptive": DisplayServer.VSYNC_ADAPTIVE,
    "Fasted": DisplayServer.VSYNC_MAILBOX,
}