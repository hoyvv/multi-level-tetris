## Утилитарный класс для безопасного формирования путей файловой системы.
##
## Предоставляет методы для корректного соединения путей к файлам и папкам.
extends RefCounted
class_name PathBuilder

## Формирует полный путь к файлу с учетом расширения.[br]
## [b]base_path[/b] — папка, в которой находится файл (например, "user://saves").[br]
## [b]file_name[/b] — имя файла без расширения.[br]
## [b]extension[/b] — расширение файла. Если точка в начале отсутствует, она будет добавлена автоматически.
static func build_path(base_path: String, file_name: String, extension: String = "") -> String:
	var full_path: String = base_path.path_join(file_name)
	
	if extension:
		if not extension.begins_with("."):
			extension = "." + extension
		full_path += extension
		
	return full_path

## Формирует путь к директории и гарантирует наличие закрывающего слэша.[br]
## [b]base_path[/b] — родительская папка.[br]
## [b]directory_name[/b] — название новой или целевой папки.[br]
## Возвращает строку, заканчивающуюся символом [code]/[/code].
static func build_directory_path(base_path: String, directory_name: String) -> String:
	var full_path: String = base_path.path_join(directory_name)
	
	if not full_path.ends_with("/"):
		full_path += "/"
		
	return full_path