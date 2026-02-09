extends RefCounted
class_name VisualBridge

var _visual_effects: VisualEffects

var _piece: Piece
var _field: Node2D

var _last_lean_dir_x: int = 0

func _init(board: Board, piece: Piece, effect_settings: EffectSettings, field: Node2D) -> void:
	board.line_cleared.connect(_on_line_clear)
	_piece = piece
	_field = field
	_visual_effects = VisualEffects.new(effect_settings)

	_piece.lock_timer_started.connect(_on_piece_lock_timer_started)
	_piece.lock_timer_stopped.connect(_on_piece_lock_timer_stopped)
	_piece.landing_requested.connect(_on_piece_landing_requested)
	_piece.wall_hit.connect(_on_piece_wall_hit)

func _on_line_clear(multiplier: int) -> void:
	_visual_effects.line_clear(_field, multiplier, true)

func _on_piece_lock_timer_stopped() -> void:
	_visual_effects.reset_piece_visula_lock(_field, _piece.tilelayer)

func _on_piece_lock_timer_started() -> void:
	_visual_effects.set_piece_visual_lock(_field, _piece.tilelayer, _piece.lock_timer.wait_time)

func _on_piece_landing_requested(_p: Piece) -> void:
	_visual_effects.lock(_field)

func _on_piece_wall_hit(direction_x: int) -> void:
	var target_lean_dir: int = 0

	if direction_x:
		target_lean_dir = direction_x

	if direction_x == _last_lean_dir_x:
		return

	_last_lean_dir_x = target_lean_dir

	if direction_x:
		_visual_effects.lean_field(_field, direction_x)
	else:
		_visual_effects.return_field(_field)
