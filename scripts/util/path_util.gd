class_name PathUtil

static func build_path(base_path: String, name: String, extension: String = "") -> String:
	if extension != "" and not extension.begins_with("."):
		extension = "." + extension
		
	return "%s%s%s" % [base_path, name, extension]

static func build_directory_path(base_path: String, directory_name: String) -> String:
	return "%s%s/" % [base_path, directory_name]