class_name ScreenFlash extends ColorRect

signal finished()

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_animation_player.play("RESET")
	
func play(anim: String) -> void:
	_animation_player.play(anim)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	emit_signal("finished")
	queue_free()
