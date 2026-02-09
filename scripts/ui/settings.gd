extends Control

@export var resolution_option: OptionButton
@export var fullscreen_check: CheckBox
@export var borderless_check: CheckBox
@export var vsync_check: CheckBox



func _ready() -> void:
	var resolutions : Array = [
		Vector2i(1920, 1080),
		Vector2i(1600, 900),
		Vector2i(1280, 720),
		Vector2i(640,360),
		Vector2i(320,180)
	]
	for res : Vector2i in resolutions:
		resolution_option.add_item("%dx%d" % [res.x, res.y])
	
	load_current_settings()
	
	resolution_option.item_selected.connect(_on_resolution_selected)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	

func load_current_settings() -> void:
	var mode : int = DisplayServer.window_get_mode()
	fullscreen_check.button_pressed = mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	borderless_check.button_pressed = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	vsync_check.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
 
	var window_size : Vector2i = DisplayServer.window_get_size()
	for i in range(resolution_option.item_count):
		var res_text : String = resolution_option.get_item_text(i)
		var parts : Array = res_text.split("x")
		if parts.size() == 2 and int(parts[0]) == window_size.x and int(parts[1]) == window_size.y:
			resolution_option.select(i)
			break

func _on_resolution_selected(index: int) -> void:
	var text : String = resolution_option.get_item_text(index)
	var parts : Array = text.split("x")
	if parts.size() == 2:
		DisplayServer.window_set_size(Vector2i(int(parts[0]), int(parts[1])))

func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_on_resolution_selected(0)

func _on_borderless_toggled(enabled: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, enabled)

func _on_vsync_toggled(enabled: bool) -> void:
	var mode : int = DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value)

func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)
