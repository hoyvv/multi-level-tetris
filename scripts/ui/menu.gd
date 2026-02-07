extends Control

@onready var settings: Control = $Settings
@onready var panel: Panel = $Panel

func _ready() -> void:
	pass

func _on_play_btn_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/main_level/main_level.tscn")

func _on_stngs_btn_pressed() -> void:
	settings.show()
	panel.hide()
	
func _on_exit_btn_pressed() -> void:
	get_tree().quit()

func _on_back_btn_pressed() -> void:
	settings.hide()
	panel.show()
