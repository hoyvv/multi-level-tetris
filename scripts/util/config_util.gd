extends RefCounted
class_name ConfigUtil

static func load_config(path: String) -> ConfigFile:
	var config: ConfigFile = null

	if FileAccess.file_exists(path):
		config = ConfigFile.new()
		config.load(path)

	return config

static func set_config_dict(data: Dictionary) -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	for section_key: String in data.keys():
		for key: String in data[section_key].keys():
			config.set_value(section_key, key, data[section_key][key])
			print(section_key, " ", key)
	
	return config

static func set_config_array(data: Array[Dictionary]) -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	for dict: Dictionary in data:
		for property: String in dict.keys():
			config.set_value(dict["name"], property, dict[property])

	return config