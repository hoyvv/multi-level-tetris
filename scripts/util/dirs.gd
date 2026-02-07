## Утилитарный класс для управления директориями.
##
## Предоставляет методы для создания папок и получения их списка. 
## Взаимодействует с [PathBuilder] для формирования корректных путей.
extends RefCounted
class_name Dirs

## Создает список папок по указанному пути.[br]
## [b]path[/b] — базовый путь, где будут созданы папки.[br]
## [b]folders_name[/b] — массив имен папок для создания.
static func create_folders(path: String, folders_name: Array[String]) -> void:
	for folder_name in folders_name:
		var folder_path: String = PathBuilder.build_directory_path(path, folder_name)
		if not DirAccess.dir_exists_absolute(folder_path):
			DirAccess.make_dir_absolute(folder_path)


## Рекурсивно создает структуру папок.[br]
## Позволяет создать путь любой вложенности за один вызов, 
## например: [i]"saves/levels/current"[/i].
static func create_folders_recursive(path: String, folders_name: String) -> void:
	var folder_path: String = PathBuilder.build_directory_path(path, folders_name)
	DirAccess.make_dir_recursive_absolute(folder_path)


## Возвращает массив имен всех папок внутри указанной директории.[br]
## Если путь невалиден или папка не существует, возвращает пустой массив.
static func get_directory(directory_path: String) -> PackedStringArray:
	var dir: DirAccess = DirAccess.open(directory_path)
	if DirAccess.get_open_error() == OK:
		return dir.get_directories()
	return []
