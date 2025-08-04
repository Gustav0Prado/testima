extends Control

enum {
	ATTACK,
	DEFEND,
} 

const DEFAULT_WAIT_TIME: float = 0.5

@onready var _enemies_menu: Menu = $EnemiesMenu
@onready var _options_menu: Menu = $Menu/Options/Menu

var event_queue: Array = []
var current_player_index: int = 0
var current_action : int = -1
var party: Array = [Data.player]

func _ready() -> void:
	# Removes mouse input from the game
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Connects buttons to this object
	_enemies_menu.connect_buttons_to_object(self, "enemy_button")
	_options_menu.connect_buttons_to_object(self, "options_button")
	
	# Starts on options menu first option 
	_options_menu.focus_button()

#func _on_menu_button_focused(button: BaseButton) -> void:
	#print(button.text)

#func wait(time: int) -> void:
	#await get_tree().create_timer(time).timeout

func add_event(actor: BattleActor, type: int, target: Object) -> void:
	event_queue.append([actor, type, target])

func run_event(actor: BattleActor, type: int, target: Object) -> void:
	match type:
		ATTACK:
			print(actor.name + " wacks " + target.name)
			target.heal_hurt(-1)
			await get_tree().create_timer(DEFAULT_WAIT_TIME).timeout
		DEFEND:
			print(actor.name + " defends!")
			await await get_tree().create_timer(DEFAULT_WAIT_TIME).timeout
		_:
			pass

func run_through_event_queue() -> void:
	for event in event_queue:
		await run_event(event[0], event[1], event[2])
		
	event_queue.clear()
	_options_menu.focus_button()

func _on_menu_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			current_action = ATTACK
			_enemies_menu.focus_button()
		_:
			pass

func _on_enemies_menu_button_pressed(enemy_button: Enemy_Button) -> void:
	add_event(Data.player, current_action, enemy_button.battle_actor)
	
	current_player_index += 1
	if current_player_index < party.size():
		_options_menu.focus_button()
	else:
		var focus_owner: Control = get_viewport().gui_get_focus_owner()
		focus_owner.release_focus()
		current_player_index = 0
		for enemy_btn in _enemies_menu._buttons:
			add_event(enemy_btn.battle_actor, Util.choose([ATTACK, DEFEND]), Util.choose(party))
		run_through_event_queue()
