class_name DirectoryUtil

static func _get_folder_path(folder_path: String, folder_name: String) -> String:
	return PathUtil.build_directory_path(folder_path, folder_name)

static func create_folders(path: String, folders_name: Array[String]) -> void:
		var _folder_path: String
		if folders_name.size() > 1:
			for folder_name in folders_name:
				_folder_path = PathUtil.build_directory_path(path, folder_name)
				if not DirAccess.dir_exists_absolute(_folder_path):
					DirAccess.make_dir_absolute(_folder_path)
		else:
			_folder_path = PathUtil.build_directory_path(path, folders_name[0])
			DirAccess.make_dir_absolute(_folder_path)

static func create_folders_recursive(path: String, folders_name: String) -> void:
	var folder_path: String = PathUtil.build_directory_path(path, folders_name)
	DirAccess.make_dir_recursive_absolute(folder_path)

static func get_directory(directory_path: String) -> PackedStringArray:
	var dir: DirAccess = DirAccess.open(directory_path)
	return dir.get_directories()
