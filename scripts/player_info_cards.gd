class_name PlayerInfoCards extends VBoxContainer

@onready var _cards: Array = get_children()

func _ready() -> void:
	for i in range(Data.party.size()):
		var card: PlayerInfoCard = _cards[i]
		card.set_battle_actor(Data.party[i])
