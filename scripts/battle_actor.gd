class_name BattleActor extends Resource

signal hp_changed(hp: int, value_change: int)

var name : String = ""
var hp_max: int = 1
var hp: int = hp_max
var speed: int = -1
var texture: Texture = null
var xp: int = -1
var gold: int = -1
var level: int = -1

func _init(_hp: int = hp_max, _speed: int = speed, _level: int = level) -> void:
	self.hp_max = _hp
	self.hp = hp_max
	
	self.speed = _speed
	self.level = _level
	
	self.xp = level * 5
	self.gold = level * 3

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
	dup._init(hp_max, speed, level)
	dup.name = name
	dup.texture = texture
	return dup

func speed_roll() -> int:
	var spread: int = 4
	return speed + randi_range(-spread, spread)
