extends Node2D

@export var line_color: Color = Color(1, 1, 1, 0.2)
@export var line_width: float = 1.0

signal position_changed(position: Vector2)

func _ready() -> void:
    _update_field_transform()
    get_viewport().size_changed.connect(_update_field_transform, CONNECT_DEFERRED)

func _update_field_transform() -> void:
    var full_board_size: Vector2 = Vector2(
        GameConstant.COLS + GameConstant.BORDER * 2,
        GameConstant.ROWS + GameConstant.BORDER * 2
    ) * GameConstant.TILE_SIZE

    var screen_size: Vector2 = DisplayServer.window_get_size()

    var new_scale: float = clampf((screen_size.y / full_board_size.y) / 1.3, 0.1, 1.1)
    var new_size: Vector2 = full_board_size * new_scale

    scale = Vector2(new_scale, new_scale)
    position = (screen_size / 2.0) - (new_size / 2.0)

    position_changed.emit(position)
 
func _draw() -> void:
    _draw_grid()

func _draw_grid() -> void:
    var new_grid_size: Vector2i = Vector2i(GameConstant.COLS, GameConstant.ROWS) + Vector2i(2, 2)
    var tile_size: int = GameConstant.TILE_SIZE
    var adaptive_width: float = line_width / scale.x

    var points: PackedVector2Array = PackedVector2Array()
    points.resize((new_grid_size.x + new_grid_size.y) * 2)
    
    var idx: int= 0

    for x: int in range(new_grid_size.x):
        points[idx] = Vector2(x * tile_size, 0)
        points[idx + 1] = Vector2(x * tile_size, new_grid_size.y * tile_size)
        idx += 2

    for y: int in range(new_grid_size.y):
        points[idx] = Vector2(0, y * tile_size)
        points[idx + 1] = Vector2(new_grid_size.x * tile_size, y * tile_size)
        idx += 2

    draw_multiline(points, line_color, adaptive_width)

