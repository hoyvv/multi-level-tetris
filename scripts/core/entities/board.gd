extends RefCounted
class_name Board

signal spawn_next_piece
signal line_cleared(amount: int)

var tilelayer: TileMapLayer

func _init(_tilelayer: TileMapLayer) -> void:
	tilelayer = _tilelayer

func process_landing(piece: Piece) -> void:
	_land_piece(piece)
	_check_rows()
	
	spawn_next_piece.emit()

func clear() -> void:
	for row: int in range(GameConstant.ROWS):
		for col: int in range(GameConstant.COLS):
			tilelayer.erase_cell(Vector2i(col + 1, row + 1))

func _check_rows() -> void:
	var row: int = GameConstant.ROWS
	var lines_cleared: int = 0

	while row > 0:
		var count: int = 0
		for col: int in GameConstant.COLS:
			if not TileValidator.is_free(Vector2i(col + 1, row), tilelayer):
				count += 1

		if count == GameConstant.COLS:
			lines_cleared += 1
			
			_shift_rows(row)
		else:
			row -= 1

	if lines_cleared > 0:
		line_cleared.emit(lines_cleared)

func _shift_rows(row: int) -> void:
	var atlas: Vector2i
	for i: int in range(row, 1, -1):
		for j: int in range(GameConstant.COLS):
			atlas = tilelayer.get_cell_atlas_coords(Vector2i(j + 1, i - 1))

			if atlas == Vector2i(-1, -1):
				tilelayer.erase_cell(Vector2i(j + 1, i))
			else:
				tilelayer.set_cell(Vector2i(j + 1, i), GameConstant.AtlasId.BOARD_ATLAS_ID, atlas)

func _land_piece(piece: Piece) -> void:
	for cell_offset: Vector2i in piece.cells:
		piece.tilelayer.erase_cell(piece.position + cell_offset)
		tilelayer.set_cell(piece.position + cell_offset, GameConstant.AtlasId.BOARD_ATLAS_ID, piece.atlas)
