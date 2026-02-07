extends Panel

signal continue_game
signal exit_game

@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var setting_button: Button = $VBoxContainer/SettingsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

func _ready() -> void:
    continue_button.pressed.connect(continue_game.emit)
    exit_button.pressed.connect(exit_game.emit)
    
