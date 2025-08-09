class_name BattleActor extends Resource

signal hp_changed(hp, value_change)

var name : String = ""
var hp_max: int = 1
var hp: int = hp_max
var texture: Texture = null

func _init(_hp: int = hp_max) -> void:
	hp = _hp

func set_actor_name(_name: String) -> void:
	#name = _name.to_lower()
	name = _name
	texture = load("res://assets/battle/enemies/" + name + ".png")

func heal_hurt(value: int) -> void:
	if value == 0:
		return
	
	hp = clampi(hp+value, 0, hp_max)
	emit_signal("hp_changed", hp, value)

func duplicate_custom() -> Resource:
	var dup : BattleActor = self.duplicate()
	dup.name = name
	dup.texture = texture
	return dup
