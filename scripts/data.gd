extends Node

var enemies: Dictionary = {
	# Name | HP | Speed | Strength | Level
	"Blobby" = BattleActor.new(1, 5, 4, 2),
}

#  HP | Speed | Strength | Level
var player : BattleActor = BattleActor.new(32, 2, 1, 1)

func _ready() -> void:
	# Set keys to enemies
	var keys: Array = enemies.keys()
	for key in keys:
		enemies[key].set_actor_name(key)
	
	player.name = "Bongo"
