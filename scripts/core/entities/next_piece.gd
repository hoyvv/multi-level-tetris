extends RefCounted
class_name NextPiece

var tilelayer: TileMapLayer

var cells: Array[Vector2i]
var position: Vector2i
var atlas: Vector2i
var atlas_id: int 

func _init(piece_tilelayer: TileMapLayer, piece_position: Vector2i, piece_atlas_id: int) -> void:
	tilelayer = piece_tilelayer
	position = piece_position
	atlas_id = piece_atlas_id

func set_data(new_data: Dictionary[String, Variant]) -> void:
	cells = new_data["shape"]
	atlas = new_data["atlas"]
	
func redraw() -> void:
	clear()
	draw()
	
func draw() -> void:
	TileRenderer.draw_cells(cells, position, atlas_id, atlas, tilelayer)

func clear() -> void:
	tilelayer.clear()