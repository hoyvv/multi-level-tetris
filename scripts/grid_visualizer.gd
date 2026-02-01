extends Node2D

@export var grid_size: Vector2i = Vector2i(10, 20)
@export var cell_size: int = 32                   
@export var line_color: Color = Color(1, 1, 1, 0.2)
@export var line_width: float = 1.0               

func _draw() -> void:
	grid_size.x += 2; grid_size.y += 2
	
	for x: int in range(grid_size.x):
		var from: Vector2i = Vector2i(x * cell_size, 0)
		var to: Vector2i = Vector2i(x * cell_size, grid_size.y * cell_size)
		draw_line(from, to, line_color, line_width)
	
	for y: int in range(grid_size.y):
		var from: Vector2i = Vector2i(0, y * cell_size)
		var to: Vector2i = Vector2i(grid_size.x * cell_size, y * cell_size)
		draw_line(from, to, line_color, line_width)
