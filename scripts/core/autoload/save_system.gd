extends Node

@warning_ignore_start("UNUSED_SIGNAL")
signal loaded
signal saved
const SETTINGS_PATH: String = "user://config/settings.config"

const _USER_PATH: String = "user://"
const _SAVE_PATH: String = "user://saves/save.sav"

var save_data: Dictionary[String, Variant] = {}

func _ready() -> void:
	Dirs.create_folders(_USER_PATH, ["saves", "config"])
	
func save() -> void:
	var file: FileAccess = FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
	if file.get_error() == OK:
		file.store_var(save_data)
		saved.emit()
 
	file.close()

func load() -> Dictionary[String, Variant]:
	if not FileAccess.file_exists(_SAVE_PATH):
		return {}

	var file: FileAccess = FileAccess.open(_SAVE_PATH, FileAccess.READ)
	var result: Dictionary = {}

	if file.get_error() == OK:
		loaded.emit()
		result = file.get_var()
		
	file.close()
	return result
