class_name Overworld extends Node2D

signal enemy_encountered()

@onready var _main_map: MainMap = $MainMap
@onready var _enemy_spawn_areas: EnemySpawnAreas = $EnemySpawnAreas
@onready var _player: Player = $Player
@onready var _danger: Danger = $Danger

func _on_player_moved(pos: Vector2, run_factor: float) -> void:
	_danger.countdown(_main_map.get_threat_level(pos) + run_factor)


func _on_danger_limit_reached() -> void:
	var enemies_weighted: Array = _enemy_spawn_areas.get_enemies_weighted(_player.position)
	enemy_encountered.emit(enemies_weighted)
	# Enter battle effects
