class_name Player extends CharacterBody2D

signal moved(pos, run_factor)

const SPEED: int = 60
const IDLE_FRAME: int = 0

@onready var _animated_sprite: AnimatedSprite2D = $ForestMask/AnimatedSprite2D
@onready var _forest_mask: Sprite2D = $ForestMask

func _ready() -> void:
	_animated_sprite.play("DOWN")
	idle()

func _process(_delta: float) -> void:
	velocity = Util.get_four_directions_vector(false).normalized()
	if velocity.is_equal_approx(Vector2.ZERO):
		idle()
		return
	
	var run_factor: float = 2.0 if Input.is_action_pressed("ui_cancel") else 1.0
	
	if !_animated_sprite.is_playing():
		_animated_sprite.frame = 1
	
	_animated_sprite.speed_scale = run_factor
	_animated_sprite.play(Util.convert_vector2_to_string(velocity))
	
	velocity = velocity * SPEED * run_factor
	move_and_slide()
	moved.emit(self.position, run_factor)
	
func idle() -> void:
	_animated_sprite.frame = IDLE_FRAME
	_animated_sprite.pause()

func enable(on: bool) -> void:
	set_process(on)
	if !on: 
		idle()
