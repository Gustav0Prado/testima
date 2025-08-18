class_name EnemyInfoHBox extends HBoxContainer

@onready var _name: Label = $EnemyNames
@onready var _count: Label = $EnemyNumber

func set_enemy_name(text: String) -> void:
	_name.text = text
	
func set_enemy_count(n: int) -> void:
	_count.text = str(n)
	visible = n > 0
	
func get_enemy_name() -> String:
	return _name.text

func get_enemy_count() -> int:
	return int(_count.text)

func on_enemy_button_defeated() -> void:
	_count.text = str( int(_count.text)-1 )
