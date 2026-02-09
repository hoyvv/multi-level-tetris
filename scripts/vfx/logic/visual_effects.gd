extends RefCounted
class_name VisualEffects

var _effect_settings: EffectSettings 

var _lean_tween: Tween
var _lock_tween: Tween
var _impact_tween: Tween

var _last_lean_shift: float = 0
var _current_impact_priority: bool = false

func _init(effect_settings: EffectSettings) -> void:
	_effect_settings = effect_settings
	
func lock(field: Node2D, priority: bool = false) -> void:
	_shake_node(field, _effect_settings.lock_intensity, _effect_settings.lock_start_duration, _effect_settings.lock_end_duration, priority)

func line_clear(field: Node2D, multiplier: int, priority: bool = false) -> void:
	_shake_node(field, _effect_settings.cb_intensity * multiplier, _effect_settings.cb_start_duration, _effect_settings.cb_end_duration, priority)

func set_piece_visual_lock(field: Node2D, piece_tilelayer: TileMapLayer, lock_time: float) -> void:
	_tween_kill(_lean_tween)
	
	_lock_tween = field.create_tween()
	_lock_tween.tween_property(piece_tilelayer, "modulate:a", _effect_settings.lock_min_alpha_threshold, lock_time)
	await _lock_tween.finished
	piece_tilelayer.modulate.a = 1	
		
func reset_piece_visula_lock(field: Node2D, piece_tilelayer: TileMapLayer) -> void:
	_tween_kill(_lock_tween)

	_lock_tween = field.create_tween()
	_lock_tween.tween_property(piece_tilelayer, "modulate:a", 1, _effect_settings.lock_min_alpha_threshold)

func lean_field(field: Node2D, direction_x: int) -> void: 
	var shift: float = direction_x * _effect_settings.lean_amount

	_tween_kill(_lean_tween)
	
	_lean_tween = field.create_tween()
	_lean_tween.tween_property(field, "position:x", shift, 0.1)\
	.as_relative()\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT)

	_last_lean_shift =+ shift

func return_field(field: Node2D) -> void:
	_tween_kill(_lean_tween)

	_lean_tween = field.create_tween()
	_lean_tween.tween_property(field, "position:x", -_last_lean_shift, 0.3)\
	.as_relative()\
	.set_trans(Tween.TRANS_BACK)\
	.set_ease(Tween.EASE_OUT)
	print(_last_lean_shift)

func _shake_node(node: Node2D, intensity: float, start_duration: float, end_duration: float, priority: bool = false , ) -> void:
	if _current_impact_priority and not priority:
		return

	_current_impact_priority = priority

	_tween_kill(_impact_tween)

	_impact_tween = node.create_tween()

	_impact_tween.tween_property(node, "position:y", intensity, start_duration)\
	.as_relative()\
	.set_trans(Tween.TRANS_LINEAR)\
	.set_ease(Tween.EASE_OUT)

	_impact_tween.tween_property(node, "position:y", -intensity, end_duration)\
	.as_relative()\
	.set_trans(Tween.TRANS_BACK)\
	.set_ease(Tween.EASE_OUT)

	_impact_tween.finished.connect(func() -> void: _current_impact_priority = false)
	
func _tween_kill(tween: Tween) -> void:
	if tween and tween.is_valid():
		tween.kill()
