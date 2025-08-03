extends Node

var enemies: Dictionary = {
	"Blobby" = BattleActor.new(),
}

func _ready() -> void:
	var keys: Array = enemies.keys()
	for key in keys:
		enemies[key].set_actor_name(key)
