class_name Enemy_Button extends TextureButton

@onready var _hit: Timer = $Hit
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var hp_max: int = 1
var hp: int = hp_max

func _ready() -> void:
	_animation_player.play("RESET")
	set_process(false)

# Hit effect
func _process(_delta: float) -> void:
	self_modulate.a = randf()

func _on_focus_entered() -> void:
	_animation_player.play("highlight")

func _on_focus_exited() -> void:
	_animation_player.play("RESET")

func heal_hurt(value: int) -> void:
	hp = clampi(hp+value, 0, hp_max)
	
	# Taking damage
	if value < 0:
		set_process(true)
		_hit.start()
		await _hit.timeout
		set_process(false)
		self_modulate.a = 1.0
