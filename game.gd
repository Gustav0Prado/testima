class_name Game extends Node2D

const BATTLE: PackedScene = preload("res://Battle/scenes/battle.tscn")

@onready var _overworld: Overworld = $Overworld
@onready var _player: Player = $Overworld/Player
@onready var _canvas_layer0: CanvasLayer = $CanvasLayer0
@onready var _fade_transition: FadeTransition = $FadeTransition

func _on_overworld_enemy_encountered(enemies_weighted: Array) -> void:
	_player.enable(false)
	await Util.screen_flash(_canvas_layer0, "battle_start", false).tree_exiting
	remove_child(_overworld)
	
	var inst = BATTLE.instantiate()
	inst.enemies_weighted = enemies_weighted
	
	await get_tree().process_frame
	_canvas_layer0.add_child(inst)
	await inst.tree_exited
	
	add_child(_overworld)
	_fade_transition.fade_out(Color.BLACK)
	_player.enable(true)
