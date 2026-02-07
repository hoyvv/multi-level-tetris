extends RefCounted
## Не использвать
class_name PieceSpawner

var current_piece: Piece
var next_piece: NextPiece

var _piece_tilelayer: TileMapLayer
var _next_piece_tilelayer: TileMapLayer
var _ghost_tilelayer: TileMapLayer

var _shape_provider: ShapeProvider = ShapeProvider.new()

func _init(piece_tilelayer: TileMapLayer, next_piece_tilelayer: TileMapLayer,  ghost_tilelayer: TileMapLayer) -> void:
    _piece_tilelayer = piece_tilelayer
    _next_piece_tilelayer = next_piece_tilelayer
    _ghost_tilelayer = ghost_tilelayer

func setup_pieces(lock_timer: Timer) -> void:
    current_piece = Piece.new(_piece_tilelayer, _ghost_tilelayer, GameConstant.START_POSITION, GameConstant.AtlasId.PIECE_ATLAS_ID, lock_timer)
    next_piece = NextPiece.new(_next_piece_tilelayer, GameConstant.NEXT_DRAW_POSITION, 0)

    current_piece.cells = _shape_provider.get_shape()
    current_piece.atlas = _shape_provider.get_atlas_for(current_piece.cells)

    next_piece.cells = _shape_provider.get_shape()
    next_piece.atlas = _shape_provider.get_atlas_for(next_piece.cells)
    

    
