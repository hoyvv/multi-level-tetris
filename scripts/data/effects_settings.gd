extends Resource
class_name EffectSettings

@export_group("Piece Lock Impact")
## Сила встряски поля в момент фиксации фигуры
@export_range(0.0, 20.0, 0.1) var lock_intensity: float = 2.0
## Минимальная прозрачность (альфа канал), до которой затухает фигура при локе,
## используеться только если фигура упала под действием гравитации
@export_range(0.0, 1.0, 0.05) var lock_min_alpha_threshold: float = 0.3

@export_subgroup("Lock Animation Timings")
## Время за которое поле дойдет то точки интерполяции
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var lock_start_duration: float = 0.1
## Время за которое поле дойдет то точки интерполяции
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var lock_end_duration: float = 0.2

@export_group("Combo Impact")
## Интенсивность импакта при сборе одного ряда, если больше одного ряда то cb_intensity * lines_cleared
@export_range(0.0, 100, 0.1) var cb_intensity: float = 70

@export_subgroup("Impact Animation Timings")
## Время за которое поле дойдет то точки интерполяции
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var cb_start_duration: float = 0.1
## Время за которое поле вернеться из точки интерполяции
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var cb_end_duration: float = 0.2

@export_group("Board Lean")
## Величина сдвига поля в пикселях при столкновении
@export_range(0.0, 50.0, 0.5, "suffix:px") var lean_amount: float = 3.0
## Длительность возвращения поля в исходное состояние
@export_range(0.0, 0.5, 0.01, "suffix:s") var lean_return_duration: float = 0.15
# ## Тип сглаживания анимации возврата 
# @export var bump_transition_type: Tween.TransitionType = Tween.TRANS_SINE