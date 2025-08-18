class_name HitText extends Label

var ystart: float = 0.0
var float_distance: float = 32.0
	
func init(amount: int, target: Control) -> void:
	# Add to tree before calling init
	
	if target == null:
		queue_free()
		return
	
	text = str(abs(amount)) if amount != 0 else "MISS"
	
	if amount > 0:
		modulate = Color.GREEN_YELLOW
	
	global_position = target.global_position + target.size * 0.75
	float_up_and_fade_out()

func float_up_and_fade_out() -> void:
	var _tween = create_tween()
	
	_tween.tween_property(self, "position:y", ystart + float_distance, 1.0)
	await _tween.finished
	fade_out()
	
func fade_out() -> void:
	var _tween = create_tween()
	
	_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await _tween.finished
	queue_free()
