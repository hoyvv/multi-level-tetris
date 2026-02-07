class_name ShapesData

const WALL_KICK: PackedVector2Array = [
		Vector2i(0, 0),   
		Vector2i(-1, 0),  
		Vector2i(1, 0),  
		Vector2i(-2, 0),
        Vector2i(2, 0),   
		Vector2i(1, 0),   
	]

const I : Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
const T : Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const O : Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
const Z : Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
const S : Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
const L : Array[Vector2i] = [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const J : Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]

const SHAPES_LIST: Array[Array] = [I, T, O, Z, S, L, J]

