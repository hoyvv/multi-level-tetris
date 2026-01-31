extends CanvasLayer

@onready var new_game: Button = $NewGameButton
@onready var game_over_label: Label = $GameOverLabel
@onready var score_label: Label = $ScoreLabel
@onready var max_score_lebel: Label = $MaxScoreLabel
@onready var time_left_label: Label = $TimeLeftLabel
@onready var win_label: Label = $WinLabel
@onready var label_2: Label = $Label2
@onready var lvl_label: Label = $LvlLabel
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var pause_button: Button = $PauseButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	pause_button.pressed.connect(func() -> void: SignalBus.toggele_pause.emit())
	new_game.pressed.connect(func() -> void: SignalBus.new_game.emit())
	pause_menu.continue_btn.pressed.connect(func() -> void: SignalBus.toggele_pause.emit())
	pause_menu.exit_btn.pressed.connect(func() -> void: SignalBus.exit.emit())

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SignalBus.toggele_pause.emit()
   