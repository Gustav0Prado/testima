class_name Enemy_Button extends TextureButton

var battle_actor: BattleActor = null

const HIT_TEXT: PackedScene = preload("res://scenes/hit_text.tscn")

@onready var _hit: Timer = $Hit
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_animation_player.play("RESET")
	set_process(false)
	
	var ba : BattleActor = Util.choose(Data.enemies.values())
	set_battle_actor(ba)

# Hit effect
func _process(_delta: float) -> void:
	self_modulate.a = randf()

func set_battle_actor(_battle_actor: BattleActor) -> void:
	battle_actor = _battle_actor.duplicate_custom()
	
	var callable = Callable()
	callable = Callable(self, "_on_battle_actor_hp_changed")
	battle_actor.connect("hp_changed", callable)
	
	texture_normal = battle_actor.texture

func _on_focus_entered() -> void:
	_animation_player.play("highlight")

func _on_focus_exited() -> void:
	_animation_player.play("RESET")

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
	if hp == 0:
		focus_mode = FOCUS_NONE
		_animation_player.play("exit")
		await _animation_player.animation_finished
		queue_free()
