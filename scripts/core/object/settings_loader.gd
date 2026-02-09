extends RefCounted
class_name SettingsLoader

var config: ConfigFile:
	get():
		if not FileAccess.file_exists(SaveSystem.SETTINGS_PATH):
			set_default_settings()
		else:
			load_settings()
		print(config)
		return config

func load_settings() -> void:
	config = ConfigUtil.load_config(SaveSystem.SETTINGS_PATH)
	
func set_default_settings() -> void:
	config = ConfigUtil.set_config_dict(DefaultSettings.SETTINGS)
	config.save(SaveSystem.SETTINGS_PATH)

# func load_video_settings() -> void:
#     DisplayServer.window_set_mode(settings_config.get_value("Video", "screen_mode", DisplayServer.WINDOW_MODE_FULLSCREEN))

#     DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, settings_config.get_value("Video", "borderless", false))

#     DisplayServer.window_set_vsync_mode(settings_config.get_value("Video", "vsync", DisplayServer.VSYNC_DISABLED))
