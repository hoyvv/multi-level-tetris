## Статическая утилита для визуализации клеток на [TileMapLayer].
##
## Предоставляет методы для отрисовки и очистки группы клеток (фигур) 
extends RefCounted
class_name TileRenderer

## Отрисовывает массив клеток на указанном слое.[br]
## [b]cells[/b] — массив локальных координат клеток фигуры (относительно центра фигуры).[br]
## [b]position[/b] — глобальная позиция фигуры на сетке [TileMapLayer].[br]
## [b]atlas_id[/b] — ID используемого набора тайлов (TileSet).[br]
## [b]atlas[/b] — координаты конкретного тайла в атласе.
static func draw_cells(cells: Array[Vector2i], position: Vector2i, atlas_id: int, atlas: Vector2i, tilelayer: TileMapLayer) -> void:
	for cell_offset : Vector2i in cells:
		tilelayer.set_cell(position + cell_offset, atlas_id, atlas)

## Удаляет (очищает) клетки на указанном слое по заданным координатам.[br]
## [b]cells[/b] — массив локальных координат клеток (относительно центра фигуры).[br]
## [b]position[/b] — глобальная позиция фигуры на сетке [TileMapLayer].[br]
static func clear_cells(cells: Array[Vector2i], position: Vector2i, tilelayer: TileMapLayer) -> void:
	for cell_offset: Vector2i in cells:
		tilelayer.erase_cell(position + cell_offset)