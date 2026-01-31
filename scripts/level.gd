extends Node2D

#region Variables/Constants
const COLS : int = 10 # строго четные числа
const ROWS : int = 20

const STEPS_REQ : int = 45
const START_POSITION : Vector2i = Vector2i(5, 1)

const DIRECTIONS : Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
const ACCEL : float = 0.20

const REWARD : int = 100

const BOARD_ATLAS_ID : int = 0
const GHOST_ATLAS_ID : int = 1

@onready var piece_tilelayer : TileMapLayer = $Tiles/Piece
@onready var board_tilelayer : TileMapLayer = $Tiles/Board
@onready var ghost_tilelayer : TileMapLayer = $Tiles/Ghost
@onready var hud : CanvasLayer = $HUD
@onready var lvl_timer: Timer = $LevelTimer

var game_running : bool = false
var max_score : int = 0
var score : int = 0: 
	set(value):
		score = value
		if value > max_score:
			max_score = value
			save_state()

		update_stats_ui()

var shapes_data : ShapesData = ShapesData.new()
var remaining_pieces : Array[Array] 

var piece_speed : float 
var steps : Array[float]

var piece : Array[Vector2i]
var piece_position : Vector2i
var piece_size : int = 0

var ghost_position : Vector2i

var piece_type : Array[Vector2i]
var next_piece_type : Array[Vector2i]

var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

var lvl : int = 1
var timer : int = 60

#endregion

#region Node function

func _ready() -> void:
	SignalBus.toggele_pause.connect(on_toggle_pause)
	SignalBus.exit.connect(exit)
	SignalBus.new_game.connect(create_new_game)

	load_state()
	create_new_game()

func _physics_process(_delta: float) -> void:
	if not game_running:
		get_tree().paused = true
		return

	hud.time_left_label.text = "Time left: %s" % int(lvl_timer.time_left)

	if Input.is_action_pressed("ui_left"):
		steps[0] += 10

	elif Input.is_action_pressed("ui_right"):
		steps[1] += 10

	if Input.is_action_just_pressed("ui_down"):
		move_piece_to(ghost_position)

	elif  Input.is_action_just_pressed("ui_up"):
		rotate_piece()

	for i: int in range(steps.size()):
		if steps[i] >= STEPS_REQ:
			move_piece(DIRECTIONS[i])
			steps[i] -= STEPS_REQ

	steps[2] += piece_speed
	update_ghost_piece()

#endregion

#region Setup function

func setup_pieces() -> void:
	piece_type = pick_piece()
	piece_atlas = get_atlas_for(piece_type)

	next_piece_type = pick_piece()
	next_piece_atlas = get_atlas_for(next_piece_type)

func reset_variable() -> void:
	lvl_timer.wait_time = timer
	game_running = true
	score = 0
	piece_speed = 0.6
	steps = [0, 0, 0] #0:влево, 1:вправо, 2:вниз
	remaining_pieces = ShapesData.SHAPES_LIST.duplicate()

func reset_display() -> void:
	clear_piece()
	clear_board()
	clear_panel()

#endregion

#region functions for managing the figure

func pick_piece() -> Array[Vector2i]:
	if remaining_pieces.is_empty():
		remaining_pieces = ShapesData.SHAPES_LIST.duplicate()

	remaining_pieces.shuffle()
	return remaining_pieces.pop_back()

func create_piece() -> void:
	steps = [0, 0, 0]
	piece_position = START_POSITION
	piece = piece_type
	piece_size = get_piece_size(piece)

	draw_piece(piece, piece_position, BOARD_ATLAS_ID, piece_atlas, piece_tilelayer) 
	draw_piece(next_piece_type, Vector2i(31, -2), BOARD_ATLAS_ID, next_piece_atlas, piece_tilelayer) #show next piece
	
func create_next_piece() -> void:
	piece_type = next_piece_type
	piece_atlas = next_piece_atlas

	next_piece_type = pick_piece()
	next_piece_atlas = get_atlas_for(next_piece_type)

	clear_panel()
	create_piece()

func clear_piece() -> void:
	for i : Vector2i in piece:
		piece_tilelayer.erase_cell(piece_position + i)

func draw_piece(cells: Array[Vector2i], pos: Vector2i, id: int, atlas: Vector2i, tilelayer: TileMapLayer) -> void:
	for cell_offset : Vector2i in cells:
		tilelayer.set_cell(pos + cell_offset, id, atlas)

func rotate_piece() -> void:
	var rotated_cells: Array[Vector2i] = []

	for cell: Vector2i in piece:
		rotated_cells.push_back(Vector2i(piece_size - cell.y, cell.x))

	for kick: Vector2i in ShapesData.WALL_KICK:
		var test_position: Vector2i = piece_position + kick
		if can_fit_at(rotated_cells, test_position, board_tilelayer):
			clear_piece()
			piece = rotated_cells
			piece_position = test_position
			draw_piece(piece, piece_position, BOARD_ATLAS_ID, piece_atlas, piece_tilelayer)

			return
	return

func move_piece(direction: Vector2i) -> void:

	if can_move(direction):
		update_piece_position_in_direction(direction)
		return

	if direction == Vector2i.DOWN:
		process_landing()
	
func update_piece_position_in_direction(direction: Vector2i) -> void:
	clear_piece()
	piece_position += direction
	draw_piece(piece, piece_position, BOARD_ATLAS_ID, piece_atlas, piece_tilelayer)

func move_piece_to(pos: Vector2i) -> void:
	clear_piece()
	piece_position = pos
	draw_piece(piece, pos, BOARD_ATLAS_ID, piece_atlas, piece_tilelayer)
	
	if not can_move(pos):
		process_landing()
	
func update_ghost_piece() -> void:	
	ghost_position = piece_position
	ghost_tilelayer.clear()

	while can_fit_at(piece, ghost_position + Vector2i(0, 1), board_tilelayer):
		ghost_position.y += 1

	draw_piece(piece, ghost_position, GHOST_ATLAS_ID, piece_atlas, ghost_tilelayer)

#endregion

#region Validation Methods

func can_move(direction: Vector2i) -> bool:
	for point : Vector2i in piece:
		if is_free(point + piece_position + direction, board_tilelayer):
			return false
	return true

func can_fit_at(points: Array[Vector2i], pos: Vector2i, tilelayer: TileMapLayer) -> bool:
	for point: Vector2i in points:
		if is_free(point + pos, tilelayer):
			return false		
	return true

func is_free(pos: Vector2i, tilelayer: TileMapLayer) -> bool:
	return tilelayer.get_cell_source_id(pos) != -1

#endregion

#region Board methods

func check_rows() -> void:
	var row : int = ROWS

	while row > 0:
		var count: int = 0
		for i: int in range(COLS):
			if is_free(Vector2i(i + 1, row), board_tilelayer):
				count += 1
		if count == COLS:
			score += REWARD
			piece_speed += ACCEL

			shift_rows(row)
			save_state()
		else:
			row -= 1

func shift_rows(row: int) -> void:
	var atlas: Vector2i
	for i in range(row, 1, -1):
		for j in range(COLS):
			atlas = board_tilelayer.get_cell_atlas_coords(Vector2i(j + 1, i - 1))

			if atlas == Vector2i(-1, -1):
				board_tilelayer.erase_cell(Vector2i(j + 1, i))

			else:
				board_tilelayer.set_cell(Vector2i(j + 1, i), BOARD_ATLAS_ID, atlas)

func clear_board() -> void:
	for i in range(ROWS):
		for j in range(COLS):
			board_tilelayer.erase_cell(Vector2i(j + 1, i + 1))

func clear_panel() -> void:
	for i : int in range(30, 35):
		for j : int in range(-3, 1):
			piece_tilelayer.erase_cell(Vector2i(i, j))

func land_piece() -> void:
	for i : Vector2i in piece:
		piece_tilelayer.erase_cell(piece_position + i)
		board_tilelayer.set_cell(piece_position + i, BOARD_ATLAS_ID, piece_atlas)

func process_landing() -> void:
	land_piece()
	check_rows()

	if not can_fit_at(next_piece_type, START_POSITION, board_tilelayer):
		game_over()
		return
		
	create_next_piece()

func game_over() -> void:
	game_running = false
	hud.game_over_label.show()

#endregion

#region Get/Set methods

func get_atlas_for(type: Array[Vector2i]) -> Vector2i:
	return Vector2i(ShapesData.SHAPES_LIST.find(type), 0)

func get_piece_size(cells: Array[Vector2i]) -> int:
	var size: int = 0

	for cell: Vector2i in cells:
		size = max(size, max(cell.x, cell.y))

	return size

#endregion

#region SaveSystem methods

func save_state() -> void:
	var data: Dictionary = {
		"max_score": max_score,
	}
	SaveSystem.save_data(data)

func load_state() -> void:
	var data: Dictionary = SaveSystem.load_data()
	if data.is_empty():
		return

	max_score = data["max_score"]
	update_stats_ui()

#endregion

#region Signal handlers

func _on_level_timer_timeout() -> void:
	hud.win_label.show()
	game_running = false
	await get_tree().create_timer(5.0).timeout
	get_tree().paused = false
	lvl += 1
	timer += 30
	create_new_game()

func on_toggle_pause() -> void:
	hud.pause_menu.visible = !hud.pause_menu.visible
	get_tree().paused = !get_tree().paused
	game_running = !game_running
	
func exit() -> void:
	get_tree().quit()

#endregion

#region No type methods

func create_new_game() -> void:
	get_tree().paused = false

	setup_pieces()
	reset_variable()
	reset_display()
	
	ghost_tilelayer.clear()
	hud.game_over_label.hide()
	hud.win_label.hide()
	hud.pause_menu.hide()
	lvl_timer.start()
	
	create_piece()
	
func update_stats_ui() -> void:
	hud.score_label.text = "Score: %s" % score
	hud.max_score_lebel.text = "Top Score: %s" % max_score

#endregion
