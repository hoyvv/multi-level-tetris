extends Node2D

@onready var field: Node2D = $Field
@onready var piece_tilelayer: TileMapLayer = $Field/Piece
@onready var next_piece_tilelayer: TileMapLayer = $MainHUD/UI/RightPanel/VBoxContainer/NextPieceBox/PanelContainer/NextPiece
@onready var board_tilelayer: TileMapLayer = $Field/Board
@onready var ghost_tilelayer: TileMapLayer = $Field/Ghost

@onready var lock_timer: Timer = $Field/Piece/LockTimer
@onready var ui: Control = $MainHUD/UI

@export var effect_settings: EffectSettings

var game_running: bool
var game_speed: float = 0.5
var game_steps: Vector3 = Vector3.ZERO

var score: int = 0:
	set(value):
		score = value
		if max_score < value:
			max_score = value
			ui.set_max_score(value)
		ui.set_score(value)
		
var max_score: int = 0

var shape_provider: ShapeProvider = ShapeProvider.new()
var visual_bridge: VisualBridge

var board: Board 

var current_piece: Piece
var next_piece: NextPiece

func _ready() -> void:
	_load_state()

	_initialize_core()
	board.line_cleared.connect(_on_line_cleared)
	board.spawn_next_piece.connect(_on_spawn_next_piece) 
	SignalBus.new_game.connect(_on_create_new_game)
	_create_new_game()
	
func _physics_process(_delta: float) -> void:
	if not game_running:
		return

	_execute_move()
	
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not game_running:
		return

	if Input.is_action_just_pressed("space"):
		current_piece.move_piece_to(current_piece.ghost_position, board)
		return

	if  Input.is_action_just_pressed("up"):
		current_piece.rotate(board_tilelayer)
		return

func _initialize_core() -> void:
	board = Board.new(board_tilelayer)

func _initialize_bridge() -> void:
	visual_bridge = VisualBridge.new(board, current_piece, effect_settings, field)

func _update_movement_steps() -> void:
	if Input.is_action_pressed("left"):
		game_steps[0] += 10

	elif Input.is_action_pressed("right"):
		game_steps[1] += 10

	if Input.is_action_pressed("down"):
		game_steps[2] += 15

func _execute_move() -> void:
	_update_movement_steps()

	for i: int in range(3):
		if game_steps[i] >= GameConstant.STEPS_REQ:
			current_piece.move(GameConstant.DIRECTIONS[i], board_tilelayer)
			game_steps[i] -= GameConstant.STEPS_REQ
			
	game_steps[2] += game_speed
	current_piece.update(board_tilelayer)
	
func _draw_piece() -> void:
	_reset_piece()

	current_piece.redraw()
	next_piece.redraw()

	current_piece.update_ghost(ghost_tilelayer, board_tilelayer)

func _next_piece() -> void:
	current_piece.set_data({
		"shape": next_piece.cells,
		"atlas": next_piece.atlas
	})

	next_piece.set_data(shape_provider.get_rangom_piece_data())

	_draw_piece()

func _create_new_game() -> void:
	_setup_pieces()
	_reset_variable()
	_reset_display()

	_initialize_bridge()
	_draw_piece()
	
func _setup_pieces() -> void:
	current_piece = Piece.new(piece_tilelayer, ghost_tilelayer, GameConstant.START_POSITION, GameConstant.AtlasId.PIECE_ATLAS_ID, lock_timer)
	next_piece = NextPiece.new(next_piece_tilelayer, GameConstant.NEXT_DRAW_POSITION, 0)

	current_piece.set_data(shape_provider.get_rangom_piece_data())
	next_piece.set_data(shape_provider.get_rangom_piece_data())

	current_piece.landing_requested.connect(board.process_landing)

func _reset_piece() -> void:
	current_piece.position = GameConstant.START_POSITION
	current_piece.lock_moves_count = 0
	game_steps = Vector3.ZERO
	
func _reset_variable() -> void:
	game_running = true
	game_speed = 0.6
	game_steps = Vector3.ZERO
	score = 0
	lock_timer.stop()

func _reset_display() -> void:
	piece_tilelayer.clear()
	next_piece_tilelayer.clear()
	ghost_tilelayer.clear()
	board.clear()

	ui.game_over_label.hide()

func _game_over() -> void:
	game_running = false
	ui.game_over_label.show()

func _save_state() -> void:
	SaveSystem.save_data = {"max_score": max_score}
	SaveSystem.save()

func _load_state() -> void:
	var data: Dictionary = SaveSystem.load()
	if data.is_empty():
		return

	max_score = data["max_score"]
	ui.set_max_score(data["max_score"])
	
func _on_spawn_next_piece() -> void:
	if _is_game_over():
		_game_over()
		return
		
	_next_piece()
	
func _on_line_cleared(amount: int) -> void:
	score += _calculate_score(amount)
	game_speed += GameConstant.ACCEL

func _on_create_new_game() -> void:
	_create_new_game()

func _is_game_over() -> bool:
	if TileValidator.can_fit_at(next_piece.cells, GameConstant.START_POSITION, board_tilelayer):
		return false
	return true

func _calculate_score(lines: int, multiplier: int = 1) -> int:
	var result: int = 0
	match lines:
		1: result = GameConstant.REWARD
		2: result = GameConstant.REWARD * 3
		3: result = GameConstant.REWARD * 6
		4: result =	GameConstant.REWARD * 8
	
	return result * multiplier

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_state()
		
