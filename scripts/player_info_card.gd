class_name PlayerInfoCard extends HBoxContainer

var battle_actor: BattleActor = null

@onready var _name: Label = $Name
@onready var _hp: Label = $HBoxContainer/HP/Value
@onready var _mp: Label = $HBoxContainer/MP/Value
#@onready var _lvl: Label = $HBoxContainer/LVL/Value

func _ready() -> void:
	visible = battle_actor != null

func set_battle_actor(_battle_actor: BattleActor) -> void:
	battle_actor = _battle_actor
	if battle_actor:
		show()
		_name.text = battle_actor.name
		_hp.text = str(battle_actor.hp)
		_mp.text = str(battle_actor.mp)
		battle_actor.hp_changed.connect(on_battle_actor_hp_changed)
		battle_actor.mp_changed.connect(on_battle_actor_mp_changed)
	else:
		hide()

func highlight(state: bool = true) -> void:
	if state:
		_name.text = ">" + _name.text
		_name.add_theme_color_override("font_color", Color(0.737, 0.012, 0.738))
	else:
		_name.text = _name.text.substr(1)
		_name.remove_theme_color_override("font_color")

func on_battle_actor_hp_changed(hp: int, _value_change: int) -> void:
	_hp.text = str(hp)

func on_battle_actor_mp_changed(mp: int) -> void:
	_mp.text = str(mp)
