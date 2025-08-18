class_name ScreenShake extends Camera2D

@export var shake_intensity: float = 1.0
@export var shake_duration: float = 0.5

var _original_offset := Vector2.ZERO
var _time_left := 0.0

func _ready():
	_original_offset = offset

func shake():
	_time_left = shake_duration

func _process(delta):
	if _time_left > 0:
		_time_left -= delta
		offset = _original_offset + Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	else:
		offset = _original_offset
