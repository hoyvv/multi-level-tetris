extends Node

@warning_ignore_start("UNUSED_SIGNAL")
signal loaded
signal saved

const USER_PATH: String = "user://"
const SAVE_PATH: String = "user://saves/save.sav"

func _ready() -> void:
	DirectoryUtil.create_folders(USER_PATH, ["saves"])
	
func save_data(data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file.get_error() == OK:
		file.store_var(data)
		saved.emit()
 
	file.close()

func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var result: Dictionary = {}

	if file.get_error() == OK:
		loaded.emit()
		result = file.get_var()
		
	file.close()
	return result
