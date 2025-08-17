class_name EnemyInfo extends NinePatchRect

@onready var _info_boxes: Array = $VBoxContainer.get_children()

func add_enemy(enemy: BattleActor, enemy_button: Enemy_Button) -> void:
	for i in range(_info_boxes.size()):
		var info_box: EnemyInfoHBox = _info_boxes[i]
		if info_box.visible:
			if info_box.get_enemy_name() == enemy.name:
				info_box.set_enemy_count(info_box.get_enemy_count() + 1)
				return
		else:
			info_box.set_enemy_name(enemy.name)
			info_box.set_enemy_count(1)
			enemy_button.defeated.connect(info_box.on_enemy_button_defeated)
			return
