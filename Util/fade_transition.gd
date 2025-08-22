class_name FadeTransition extends CanvasLayer

signal finished()

var skip_next_fade_out: bool = false

@onready var _color_rect: ColorRect = $ColorRect
@onready var _tween: Tween = null

func _ready() -> void:
	hide()

func set_color(color: Color) -> void:
	show()
	var previous_alpha: float = _color_rect.color.a
	_color_rect.color = color
	_color_rect.color.a = previous_alpha
	
func fade_out(color: Color = _color_rect.color, duration: float = 0.5, skip: bool = false) -> void:
	_tween = create_tween()
	
	if skip_next_fade_out:
		skip_next_fade_out = false
		finished.emit()
		return
	
	set_color(color)
	
	if skip:
		_color_rect.color.a = 0.0
		return
	
	_tween.tween_property(_color_rect, "color:a", 0.0, duration).set_trans(Tween.TRANS_CUBIC)
	await _tween.finished
	finished.emit()
	
func fade_in(color: Color = _color_rect.color, duration: float = 0.5, skip: bool = false) -> void:
	_tween = create_tween()
	
	set_color(color)
	
	if skip:
		_color_rect.color.a = 1.0
		return
	
	_tween.tween_property(_color_rect, "color:a", 1.0, duration).set_trans(Tween.TRANS_CUBIC)
	await _tween.finished
	finished.emit()
