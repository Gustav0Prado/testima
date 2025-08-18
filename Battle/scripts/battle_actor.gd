class_name BattleActor extends Resource

signal hp_changed(hp: int, value_change: int)
signal mp_changed(mp: int)

var name : String = ""
var texture: Texture = null

var hp_max: int = -1
var hp: int = hp_max
var mp_max: int = -1
var mp: int = mp_max
var speed: int = -1
var strength: int = -1 

var xp: int = -1
var gold: int = -1
var level: int = -1

var is_defending: bool = false

func _init(_hp: int = hp_max, _mp: int = mp_max, _speed: int = speed, _strength: int = strength, _level: int = level) -> void:
	self.hp_max = _hp
	self.mp_max = _mp
	self.hp = hp_max
	self.mp = mp_max
	self.speed = _speed
	self.strength = _strength
	
	self.level = _level
	self.xp = level * 5
	self.gold = level * 3

func set_actor_name(_name: String) -> void:
	#name = _name.to_lower()
	name = _name
	texture = load("res://Battle/assets/battle/enemies/" + name + ".png")

func heal_hurt(value: int) -> int:
	if value == 0:
		return 0
	
	var spread: float = 0.2
	if value < 0 and is_defending:
		value *= 0.5 + randf_range(-spread, spread)
	
	hp = clampi(hp+value, 0, hp_max)
	hp_changed.emit(hp, value)
	
	return value

func add_mp(value: int) -> void:
	mp = clampi(mp + value, 0, mp_max)
	mp_changed.emit(mp)

func speed_roll() -> int:
	return Util.add_with_random_spread(speed, speed * 0.25)

func damage_roll():
	return -Util.add_with_random_spread(strength, strength * 0.25)

func defend() -> void:
	is_defending = true

func duplicate_custom() -> Resource:
	var dup : BattleActor = self.duplicate()
	dup._init(hp_max, mp_max, speed, strength, level)
	dup.name = name
	dup.texture = texture
	return dup
