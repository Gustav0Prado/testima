extends Node

var enemies: Dictionary = {
	# Name -------------| HP | MP | Speed | Strength | Level
	"Blobby" = BattleActor.new(1, 0, 1, 4, 1),
	"Bat"    = BattleActor.new(1, 0, 5, 2, 1),
	"Cocky Roach" = BattleActor.new(1, 5, 2, 3, 2),
}

var party: Array = [
	# HP | MP | Speed | Strength | Level
	BattleActor.new(32, 10, 2, 2, 1),
	BattleActor.new(21, 16, 3, 1),  	
]

func _ready() -> void:
	# Set keys to enemies
	var keys: Array = enemies.keys()
	for key in keys:
		enemies[key].set_actor_name(key)
	
	party[0].name = "Bango"
	party[1].name = "Bengo"
