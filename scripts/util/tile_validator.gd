## Статическая утилита для проверки столкновений и валидации позиций на поле.
##
## Этот класс отвечает за "физику" игры, проверяя, свободны ли клетки 
## и может ли фигура занимать определенное пространство в [TileMapLayer].
extends RefCounted
class_name TileValidator

## Проверяет, свободна ли конкретная клетка.[br]
## [b]position[/b] — координаты клетки на сетке TileMap.[br]
static func is_free(position: Vector2i, tilelayer: TileMapLayer) -> bool:
	return tilelayer.get_cell_source_id(position) == -1

## Проверяет возможность перемещения фигуры в заданном направлении.[br]
## [b]cells[/b] — массив локальных координат клеток фигуры (относительно центра фигуры).[br]
## [b]direction[/b] — вектор сдвига (например, влево, вправо или вниз).[br]
## [b]position[/b] — текущая базовая позиция фигуры на поле.[br]
static func can_move(cells: Array[Vector2i], direction: Vector2i, position: Vector2i, tilelayer: TileMapLayer) -> bool:
	for cell_offset : Vector2i in cells:
		if not is_free(cell_offset + position + direction, tilelayer):
			return false
	return true

## Проверяет, можно ли разместить фигуру целиком в указанной позиции.[br]
## [b]cells[/b] — массив локальных координат клеток фигуры (относительно центра фигуры).[br]
## [b]target_position[/b] — позиция на поле, которую должна занять фигура.[br]
static func can_fit_at(cells: Array[Vector2i], target_position: Vector2i, tilelayer: TileMapLayer) -> bool:
	for cell_offset: Vector2i in cells:
		if not is_free(cell_offset + target_position, tilelayer):
			return false        
	return true