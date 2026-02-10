extends RefCounted
class_name Piece

const _MAX_LOCK_MOVES: int = 5

signal lock_timer_started
signal lock_timer_stopped

signal landing_requested(piece: Piece)

signal wall_hit(direction_x: int)

var tilelayer: TileMapLayer
var _ghost_tilelayer: TileMapLayer

var lock_timer: Timer
var lock_moves_count: int

var cells: Array[Vector2i]
var position: Vector2i
var atlas: Vector2i
var atlas_id: int 
var size: int

var ghost_position: Vector2i

func _init(piece_tilelayer: TileMapLayer, ghost_tilelayer: TileMapLayer, piece_position: Vector2i, piece_atlas_id: int, piece_lock_timer: Timer) -> void:
	tilelayer = piece_tilelayer
	_ghost_tilelayer = ghost_tilelayer
	lock_timer = piece_lock_timer
	position = piece_position
	atlas_id = piece_atlas_id

	lock_timer.timeout.connect(_on_lock_timer_timeout)

func update(board_tilelayer: TileMapLayer) -> void:
	check_wall_hit(board_tilelayer, Vector2(Input.get_axis("left", "right"), 0))
	
func check_wall_hit(board_tilelayer: TileMapLayer, direction: Vector2) -> void:
	if not TileValidator.can_move(cells, direction, position, board_tilelayer):
		wall_hit.emit(direction.x)
		return

	wall_hit.emit(0)

func redraw() -> void:
	tilelayer.clear()
	TileRenderer.draw_cells(cells, position, atlas_id, atlas, tilelayer)
	
func draw() -> void:
	TileRenderer.draw_cells(cells, position, atlas_id, atlas, tilelayer)

func clear() -> void:
	tilelayer.clear()

func move(direction: Vector2i, board_tilelayer: TileMapLayer) -> void:
	if TileValidator.can_move(cells, direction, position, board_tilelayer):
		_update_piece_position_in_direction(direction)

	_check_lock(board_tilelayer)
	update_ghost(_ghost_tilelayer, board_tilelayer)
	
func move_piece_to(target_position: Vector2i, board: Board) -> void:
	if not TileValidator.can_fit_at(cells, target_position, board.tilelayer):
		return

	TileRenderer.clear_cells(cells, position, tilelayer)
	position = target_position
	TileRenderer.draw_cells(cells, position, atlas_id, atlas, tilelayer)

	landing_requested.emit(self)
	lock_timer.stop()

func rotate(board_tilelayer: TileMapLayer) -> void:
	if lock_moves_count >= _MAX_LOCK_MOVES:
		return
		
	var rotated_cells: Array[Vector2i] = []

	for cell: Vector2i in cells:
		rotated_cells.push_back(Vector2i(size - cell.y, cell.x))

	for kick: Vector2i in ShapesData.WALL_KICK:
		var new_position: Vector2i = position + kick
		if TileValidator.can_fit_at(rotated_cells, new_position, board_tilelayer):
			_update_lock_moves(board_tilelayer)
			
			clear()
			cells = rotated_cells
			position = new_position
			draw()

			_check_lock(board_tilelayer)
			update_ghost(_ghost_tilelayer, board_tilelayer)

			return
	return

func update_ghost(ghost_tilelayer: TileMapLayer, board_tilelayer: TileMapLayer = ghost_tilelayer) -> void:
	ghost_tilelayer.clear()
	ghost_position = position
	
	while TileValidator.can_move(cells, Vector2i.DOWN, ghost_position, board_tilelayer):
		ghost_position.y += 1

	TileRenderer.draw_cells(cells, ghost_position, atlas_id, atlas, ghost_tilelayer)

func set_data(new_data: Dictionary[String, Variant]) -> void:
	cells = new_data["shape"]
	atlas = new_data["atlas"]
	size = _calculate_size()

func _calculate_size() -> int:
	var result: int = 0

	for cell: Vector2i in cells:
		result = max(result, cell.x, cell.y)

	return result

func _update_piece_position_in_direction(direction: Vector2i) -> void:
	clear()
	position += direction
	draw()
	
func _update_lock_moves(board_tilelayer: TileMapLayer) -> void:
	if not TileValidator.can_move(cells, Vector2i.DOWN, position, board_tilelayer):
		lock_moves_count += 1

func _check_lock(board_tilelayer: TileMapLayer) -> void:
	var is_on_floor: bool = not TileValidator.can_move(cells, Vector2i.DOWN, position, board_tilelayer)

	if not is_on_floor and not lock_timer.is_stopped():
		lock_timer.stop()
		lock_timer_stopped.emit()

	if is_on_floor and lock_timer.is_stopped():
		lock_timer.start()
		lock_timer_started.emit()

func _on_lock_timer_timeout() -> void:
	landing_requested.emit(self)
