extends RefCounted
class_name ShapeProvider

var _bag: Array[Array] = []

func get_rangom_piece_data() -> Dictionary[String, Variant]:
	var shape: Array[Vector2i] = _get_next_shape()
	return {
		"shape": shape,
		"atlas": get_atlas_for(shape)
	}

func _get_next_shape() -> Array[Vector2i]:
	if _bag.is_empty():
		_bag = ShapesData.SHAPES_LIST.duplicate()
	
	_bag.shuffle()

	return _bag.pop_back()

func get_atlas_for(shape: Array) -> Vector2i:
	var index: int = ShapesData.SHAPES_LIST.find(shape)
	if index == -1:
		return Vector2i.ZERO
	
	return Vector2i(index, 0)

	
	


