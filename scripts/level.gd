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

@onready var tiles_node: Node2D = $Tiles
@onready var piece_tilelayer : TileMapLayer = $Tiles/Piece
@onready var next_piece_tilelayer : TileMapLayer = $StaticTiles/NextPiece
@onready var board_tilelayer : TileMapLayer = $Tiles/Board
@onready var ghost_tilelayer : TileMapLayer = $Tiles/Ghost
@onready var lock_timer : Timer = $LockTimer
@onready var hud : CanvasLayer = $HUD

var game_running : bool = false
var max_score : int = 0
var score : int = 0: 
	set(value):
		score = value
		if value > max_score:
			max_score = value
			save_state()

		update_stats_ui()

var lean_tween: Tween 
var flash_tween: Tween

var last_lean_dir: int = 0
var original_position: Vector2

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
	lock_timer.timeout.connect(on_timeout_lock_timer)

	SignalBus.toggele_pause.connect(on_toggle_pause)
	SignalBus.exit.connect(exit)
	SignalBus.new_game.connect(create_new_game)

	load_state()
	create_new_game()

func _physics_process(_delta: float) -> void:
	if not game_running:
		return

	var direction_x: int = int(Input.get_axis("left", "right"))

	handle_movement_input()
	
	
	for i: int in range(steps.size()):
		if steps[i] >= STEPS_REQ:
			move_piece(DIRECTIONS[i])
			steps[i] -= STEPS_REQ

	steps[2] += piece_speed
	update_ghost_piece()
	handle_visual_lean(direction_x)
	update_lock()
	
func handle_movement_input() -> void:
	if Input.is_action_pressed("left"):
		steps[0] += 10

	elif Input.is_action_pressed("right"):
		steps[1] += 10

	if Input.is_action_pressed("down"):
		steps[2] += 15

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if Input.is_action_just_pressed("space"):
		move_piece_to(ghost_position)
		apply_impact(Vector2i.DOWN, 7, 0.05, 0.7)
		return

	if Input.is_action_just_pressed("up"):
		rotate_piece()
		return

#endregion

#region Setup function

func setup_pieces() -> void:
	piece_type = pick_piece()
	piece_atlas = get_atlas_for(piece_type)

	next_piece_type = pick_piece()
	next_piece_atlas = get_atlas_for(next_piece_type)

func reset_variable() -> void:
	game_running = true
	score = 0
	piece_speed = 0.6
	steps = [0, 0, 0] #0:влево, 1:вправо, 2:вниз
	remaining_pieces = ShapesData.SHAPES_LIST.duplicate()
	original_position = tiles_node.position

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
	draw_piece(next_piece_type, Vector2i(31, -2), 1, next_piece_atlas, next_piece_tilelayer) #show next piece
	
func create_next_piece() -> void:
	piece_type = next_piece_type
	piece_atlas = next_piece_atlas

	next_piece_type = pick_piece()
	next_piece_atlas = get_atlas_for(next_piece_type)

	clear_panel()
	create_piece()

func clear_piece() -> void:
	for cell_offset: Vector2i in piece:
		piece_tilelayer.erase_cell(piece_position + cell_offset)

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

	if can_move(direction, piece_position, board_tilelayer):
		update_piece_position_in_direction(direction)
		return

func update_lock() -> void:
	var is_on_floor: bool = not can_move(Vector2i.DOWN, piece_position, board_tilelayer)

	if is_on_floor:
		if lock_timer.is_stopped():
			lock_timer.start()
			set_piece_visual_state(true)
		
func set_piece_visual_state(is_locking: bool) -> void:
	print(1)
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	
	if is_locking:
		flash_tween = create_tween()
		flash_tween.tween_property(piece_tilelayer, "modulate:a", 0.3, lock_timer.wait_time)
		await flash_tween.finished
		piece_tilelayer.modulate.a = 1	
		
func update_piece_position_in_direction(direction: Vector2i) -> void:
	clear_piece()
	piece_position += direction
	draw_piece(piece, piece_position, BOARD_ATLAS_ID, piece_atlas, piece_tilelayer)

func move_piece_to(pos: Vector2i) -> void:
	clear_piece()
	piece_position = pos
	draw_piece(piece, piece_position, BOARD_ATLAS_ID, piece_atlas, piece_tilelayer)
	
	process_landing()

func update_ghost_piece() -> void:	
	ghost_position = piece_position
	ghost_tilelayer.clear()

	while can_fit_at(piece, ghost_position + Vector2i(0, 1), board_tilelayer):
		ghost_position.y += 1

	draw_piece(piece, ghost_position, GHOST_ATLAS_ID, piece_atlas, ghost_tilelayer)

#endregion

#region Validation Methods

func can_move(direction: Vector2i, pos: Vector2i, tilelayer: TileMapLayer) -> bool:
	for point : Vector2i in piece:
		if not is_free(point + pos + direction, tilelayer):
			return false
	return true

func can_fit_at(cells: Array[Vector2i], pos: Vector2i, tilelayer: TileMapLayer) -> bool:
	for cell_offset: Vector2i in cells:
		if not is_free(cell_offset + pos, tilelayer):
			return false		
	return true

func is_free(pos: Vector2i, tilelayer: TileMapLayer) -> bool:
	return tilelayer.get_cell_source_id(pos) == -1

#endregion

#region Board methods

func check_rows() -> void:
	var row : int = ROWS
	var lines_cleared : int = 0

	while row > 0:
		var count: int = 0
		for col: int in range(COLS):
			if not is_free(Vector2i(col, row), board_tilelayer):
				count += 1

		if count == COLS:
			lines_cleared += 1

			shift_rows(row)
		else:
			row -= 1

	if lines_cleared > 0:
		score += calculate_score(lines_cleared)
		piece_speed += ACCEL
		apply_impact(Vector2i.DOWN, 25 * lines_cleared, 0.05, 0.5)
		save_state()
		
func shift_rows(row: int) -> void:
	var atlas: Vector2i
	for i: int in range(row, 1, -1):
		for j: int in range(COLS):
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
			next_piece_tilelayer.erase_cell(Vector2i(i, j))

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

func calculate_score(lines: int, multiplier: int = 1) -> int:
	var result: int = 0
	match lines:
		1: result = REWARD
		2: result = REWARD * 3
		3: result = REWARD * 6
		4: result = REWARD * 8
	
	return result * multiplier

func apply_impact(direction: Vector2, intensity: float, start_duration: float, end_duration: float) -> void:
	var impact_pos: Vector2 = tiles_node.position + (direction * intensity)

	var tween: Tween = create_tween()
	tween.tween_property(tiles_node, "position", impact_pos, start_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(tiles_node, "position", original_position, end_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func handle_visual_lean(direction_x: int) -> void:
	var can_move_now: bool = can_move(Vector2i(direction_x, 0), piece_position, board_tilelayer)
	var pressing_against_wall: bool = direction_x != 0 and not can_move_now
	var target_direction: int = direction_x if pressing_against_wall else 0

	if target_direction == last_lean_dir:
		return

	last_lean_dir = target_direction

	if last_lean_dir:
		lean_field(last_lean_dir, 3)

	else:
		return_field()

func lean_field(direction_x: int, lean_amount: int) -> void:
	if lean_tween and lean_tween.is_valid():
		lean_tween.kill()

	lean_tween = create_tween()
	lean_tween.tween_property(tiles_node, "position", original_position + Vector2(direction_x * lean_amount, 0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func return_field() -> void:
	if lean_tween and lean_tween.is_valid():
		lean_tween.kill()

	lean_tween = create_tween()
	lean_tween.tween_property(tiles_node, "position", original_position, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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

func on_toggle_pause() -> void:
	hud.pause_menu.visible = !hud.pause_menu.visible
	game_running = !game_running
	get_tree().paused = !get_tree().paused
		
func exit() -> void:
	get_tree().quit()

func on_timeout_lock_timer() -> void:
	apply_impact(Vector2i.DOWN, 7, 0.05, 0.5)
	process_landing()

#endregion

#region No type methods

func create_new_game() -> void:
	get_tree().paused = false

	setup_pieces()
	reset_variable()
	reset_display()
	
	ghost_tilelayer.clear()
	hud.game_over_label.hide()
	hud.pause_menu.hide()

	create_piece()
	
func update_stats_ui() -> void:
	hud.score_label.text = "Score: %s" % score
	hud.max_score_lebel.text = "Top Score: %s" % max_score

#endregion
