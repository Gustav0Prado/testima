extends Node

var enemies: Dictionary = {
	"Blobby" = BattleActor.new(),
}

var player : BattleActor = BattleActor.new()

func _ready() -> void:
	# Set keys to enemies
	var keys: Array = enemies.keys()
	for key in keys:
		enemies[key].set_actor_name(key)
	
	player.name = "Bongo"
