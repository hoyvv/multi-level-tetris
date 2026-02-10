extends RefCounted
class_name GameConstant

enum AtlasId {
	PIECE_ATLAS_ID = 0,
	BOARD_ATLAS_ID = 0,
}

const COLS: int = 10
const ROWS: int = 20
const BORDER: int = 1
const TILE_SIZE: int = 32 #px

const START_POSITION: Vector2i = Vector2i(5, 1)
const NEXT_DRAW_POSITION = Vector2i(1, 2)

const STEPS_REQ: int = 45
const DIRECTIONS : PackedVector2Array = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
const ACCEL : float = 0.15

const LINE_CLEAR_SCORE: Dictionary[int, int] = {
	1: 100,
	2: 300,
	3: 600,
	4: 800
}


