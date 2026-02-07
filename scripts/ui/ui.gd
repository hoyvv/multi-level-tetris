extends Control

@onready var _score_label: Label = $RightPanel/VBoxContainer/VBoxContainer/Score
@onready var _max_score_label: Label = $RightPanel/VBoxContainer/VBoxContainer/MaxScore
@onready var _new_game_button: Button = $RightPanel/VBoxContainer/NewGame
@onready var game_over_label: Label = $CenterPanel/GameOver
@onready var pause_menu: Panel = $PauseMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_new_game_button.pressed.connect(func() -> void: SignalBus.new_game.emit())
	pause_menu.continue_game.connect(_on_toggled_pause)
	pause_menu.exit_game.connect(_on_exit_game)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if Input.is_action_just_pressed("ui_cancel"):
		_on_toggled_pause()
		
func set_score(amount: int) -> void:
	_score_label.text = "Score: %s" % amount
	
func set_max_score(amount: int) -> void:
	_max_score_label.text = "Max Score %s" % amount

func _on_toggled_pause() -> void:
	pause_menu.visible = !pause_menu.visible
	owner.get_tree().paused = !owner.get_tree().paused
	
func _on_exit_game() -> void:
	get_tree().quit()
	
