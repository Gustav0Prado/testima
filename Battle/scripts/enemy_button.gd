class_name Enemy_Button extends TextureButton

signal defeated

const HIT_TEXT: PackedScene = preload("res://Battle/scenes/hit_text.tscn")

@onready var _hit: Timer = $Hit
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var battle_actor: BattleActor = null

func _ready() -> void:
	_animation_player.play("RESET")
	set_process(false)
	
	set_battle_actor(Util.choose(Data.enemies.values()))

# Hit effect
func _process(_delta: float) -> void:
	self_modulate.a = randf()

func set_battle_actor(_battle_actor: BattleActor) -> void:
	if _battle_actor:
		show()
		battle_actor = _battle_actor
		battle_actor.hp_changed.connect(_on_battle_actor_hp_changed)
		texture_normal = battle_actor.texture
	else:
		queue_free()

func _on_focus_entered() -> void:
	_animation_player.play("highlight_alt")

func _on_focus_exited() -> void:
	_animation_player.play("RESET")
	var shader_material: ShaderMaterial = material
	shader_material.set_shader_parameter("active", false)

func _on_battle_actor_hp_changed(hp: int, value_changed: int) -> void:
	# On HP change
	var inst : HitText = HIT_TEXT.instantiate()
	owner.add_child(inst)
	inst.init(value_changed, self)
	
	# Taking damage
	if value_changed < 0:
		set_process(true)
		_hit.start()
		await _hit.timeout
		set_process(false)
		self_modulate.a = 1.0
	
	# Enemy defeated
	if hp <= 0:
		focus_mode = FOCUS_NONE
		emit_signal("defeated")
		_animation_player.play("exit")
		await _animation_player.animation_finished
		queue_free()
