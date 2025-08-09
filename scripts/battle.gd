extends Control

enum {
	ATTACK,
	DEFEND,
} 

const DEFAULT_WAIT_TIME: float = 1.0
const TWEEN_DURATION: float = 0.5

@onready var _enemies_menu: Menu = $EnemiesMenu
@onready var _options_menu: Menu = $Menu/Options/Menu
@onready var _bottom: HBoxContainer = $Menu
@onready var _bottom_start_y: float = _bottom.global_position.y
@onready var _bottom_exit_y: float = DisplayServer.window_get_size()[1] + 64.0
@onready var _dialogue_box: DialogueBox = $DialogueBox
@onready var _screen_shake: ScreenShake = $ShakeCamera2D

@export var auto_advance_text: bool = false
@export var call_defend_immediately: bool = false

var event_queue: Array = []
var current_player_index: int = 0
var current_action : int = -1
var party: Array = [Data.player]

func _ready() -> void:
	# Removes mouse input from the game
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_dialogue_box.handleInput = !auto_advance_text
	_dialogue_box.hide()
	
	# Connects buttons to this object
	_enemies_menu.connect_buttons_to_object(self, "enemy_button")
	_options_menu.connect_buttons_to_object(self, "options_button")
	
	# Connects player hp_changhed to camera shake
	var callable = Callable()
	callable = Callable(self, "_on_player_hp_changed")
	Data.player.connect("hp_changed", callable)
	
	# Starts on options menu first option 
	_options_menu.focus_button()

func animate_box(obj: Object, exit: bool, offset: float):
	var tween = create_tween()
	
	var final_y : float = _bottom_exit_y if exit else _bottom_start_y
	tween.tween_property(obj, "global_position:y", final_y+offset, TWEEN_DURATION).set_trans(Tween.TRANS_CIRC)
	await tween.finished

func sort_events_by_speed(a, b) -> bool:
	var actor1: BattleActor = a[0]
	var actor2: BattleActor = b[0]
	return actor1.speed_roll() > actor2.speed_roll()
	
func sort_defends_to_top(a, b) -> bool:
	if a[1] == DEFEND:
		if b[1] == DEFEND:
			return sort_events_by_speed(a, b)
		else:
			return true
	return false
	
func sort_events() -> void:
	event_queue.sort_custom(sort_events_by_speed)
	if !call_defend_immediately:
		event_queue.sort_custom(sort_defends_to_top)

func _on_menu_button_focused(_button: BaseButton) -> void:
	pass

func add_event(actor: BattleActor, type: int, target: Object) -> void:
	event_queue.append([actor, type, target])

func run_event(actor: BattleActor, type: int, target: Object) -> void:	
	var text: Array = []
	var damage: int = -1
	
	match type:
		ATTACK:
			target.heal_hurt(damage)
			text = [
				actor.name + " wacks " + target.name + "!!",
				target.name + " takes " + str(abs(damage)) + " damage!!",
			]
			if target.hp <= 0:
				text.append(target.name + " is defeated!!")
		DEFEND:
			text = [actor.name + " defends!!"]
		_:
			pass

	_dialogue_box.add_text(text)
	if auto_advance_text:
		for _i in range(text.size()):
			await get_tree().create_timer(DEFAULT_WAIT_TIME).timeout
			_dialogue_box.advance()
	else:
		await _dialogue_box.closed

func run_through_event_queue() -> void:
	for event in event_queue:
		var actor: BattleActor = event[0]
		if actor.hp > 0:
			await run_event(event[0], event[1], event[2])
	
	# Create animation of menus going up/down
	animate_box(_dialogue_box, true, 0)
	_dialogue_box.hide()
	animate_box(_bottom, false, 0)
	
	# Clears queue and focus on options menu
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
	
	# If not last player, goes to next
	current_player_index += 1
	if current_player_index < party.size():
		_options_menu.focus_button()
	else:
		var focus_owner: Control = get_viewport().gui_get_focus_owner()
		focus_owner.release_focus()
		
		# Return to first party member
		current_player_index = 0
		
		# Each enemy does an action
		for enemy_btn in _enemies_menu._buttons:
			add_event(enemy_btn.battle_actor, Util.choose([ATTACK, DEFEND]), Util.choose(party))
		
		# Sort by speed with slight randomness
		sort_events()
		
		# Create animation of menus going down
		animate_box(_bottom, true, 0)
		
		# Runs all events in queue
		run_through_event_queue()
		
		# Animate dialogue box
		_dialogue_box.global_position.y = _bottom_exit_y
		animate_box(_dialogue_box, false, -16)
		_dialogue_box.show()

func _on_player_hp_changed(_hp: int, value_changed: int) -> void:
	if value_changed < 0:
		_screen_shake.shake()
