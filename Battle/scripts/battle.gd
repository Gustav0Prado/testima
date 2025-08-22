extends Control

enum {
	ATTACK,
	DEFEND,
} 

enum {
	ACTOR,
	ACTION_TYPE,
	TARGET
}

enum {
	VICTORY,
	DEFEAT,
}

const DEFAULT_WAIT_TIME: float = 1.0
const TWEEN_DURATION: float = 0.5

@onready var _player_info_cards: Array = $Menu/PlayerInfo/PlayerInfoCards.get_children()
@onready var _enemies_menu: Menu = $EnemiesMenu
@onready var _options_menu: Menu = $Menu/Options/Menu
@onready var _bottom: HBoxContainer = $Menu
@onready var _bottom_start_y: float = _bottom.global_position.y
@onready var _bottom_exit_y: float = DisplayServer.window_get_size()[1] + 64.0
@onready var _dialogue_box: DialogueBox = $DialogueBox
@onready var _screen_shake: ScreenShake = $ShakeCamera2D
@onready var _enemy_info: EnemyInfo = $Menu/EnemyInfo

@export var auto_advance_text: bool = false
@export var call_defend_immediately: bool = false

var enemies_weighted: Array = []
var event_queue: Array = []
var current_player_index: int = -1
var current_action : int = -1
var xp_gained: int = 0
var gold_gained: int = 0
var enemies: Array = []
var end_state: int = -1

func _ready() -> void:
	# Removes mouse input from the game
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_dialogue_box.handleInput = !auto_advance_text
	_dialogue_box.hide()
	
	# Connects buttons to this object
	_enemies_menu.connect_buttons_to_object(self, "enemy_button")
	_options_menu.connect_buttons_to_object(self, "options_button")
	
	# Connects player hp_changed to camera shake
	for player in Data.party:
		if player: player.hp_changed.connect(_on_player_hp_changed)
	
	# Connects enemies exit to battle (XP and Gold gain)
	for enemy_button: Enemy_Button in _enemies_menu.get_buttons():
		var spawn_chance: float = 1.0 - enemies.size() * 0.20
		var enemy: BattleActor = null
		if randf() < spawn_chance:
			var enemy_string: String = Util.choose_weighted(enemies_weighted)
			enemy = Data.enemies[enemy_string]
			
			enemy_button.set_battle_actor(enemy)
			enemy = enemy_button.battle_actor
		else:
			enemy_button.set_battle_actor(null)
		
		if enemy:
			enemy = enemy.duplicate_custom()
			_enemy_info.add_enemy(enemy, enemy_button)
			enemy_button.defeated.connect(
				func(): _on_enemy_button_defeated(enemy_button.battle_actor)
			)
			enemies.append(enemy)
	
	# Starts on options menu first option 
	_options_menu.focus_button()
	next_player()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _options_menu.is_focused():
			if event_queue.size() > 0:
				event_queue.pop_back()
				next_player(-1)
			else:
				# Player error sound
				pass
		elif _enemies_menu.is_focused():
			_options_menu.focus_button()
	else:
		return
	get_viewport().set_input_as_handled()

func enemies_turn() -> void:
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	focus_owner.release_focus()
	
	# Each enemy does an action
	for enemy_btn in _enemies_menu._buttons:
		add_event(enemy_btn.battle_actor, Util.choose_weighted([ATTACK, 5, DEFEND, 2]), Util.choose(Data.party))
	
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

func debug_reload():
	_dialogue_box.add_text(["Resetting in 3 seconds..."])
	await _dialogue_box.closed
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()

func animate_box(obj: Object, exit: bool, offset: float):
	var tween = create_tween()
	
	var final_y : float = _bottom_exit_y if exit else _bottom_start_y
	tween.tween_property(obj, "global_position:y", final_y+offset, TWEEN_DURATION).set_trans(Tween.TRANS_CIRC)
	await tween.finished

func sort_events_by_speed(a, b) -> bool:
	var actor1: BattleActor = a[ACTOR]
	var actor2: BattleActor = b[ACTOR]	
	return actor1.speed_roll() > actor2.speed_roll()
	
func sort_defends_to_top(a, b) -> bool:
	if a[ACTION_TYPE] == DEFEND:
		if b[ACTION_TYPE] == DEFEND:
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
	var damage: int = actor.damage_roll()
	var total_dmg: int = 0
	
	if actor.hp <= 0:
		return
	
	var target_is_player: bool = Data.party.has(target)
	
	# If not valid target, then choose new one
	if target and (target.hp <= 0):
		target = null
		
		var targets: Array = Data.party if target_is_player else enemies
		for battle_actor: BattleActor in targets:
			if battle_actor.hp > 0:
				target = battle_actor
				break
		if !target:
			type = -1
	
	match type:
		ATTACK:
			total_dmg = target.heal_hurt(damage)
			
			if total_dmg < 0:
				text = [
					actor.name + " wacks " + target.name + "!!",
					target.name + " takes " + str(abs(total_dmg)) + " damage!!",
				]
				# If not valid target, then choose new one
				if target.hp <= 0:
					text.append(target.name + " is defeated!!")
					
					target = null
					# Check if there are still targets
					var targets: Array = Data.party if target_is_player else enemies
					for battle_actor: BattleActor in targets:
						if battle_actor.hp > 0:
							target = battle_actor
							break
			elif total_dmg == 0:
				text = [
					actor.name + " wacks " + target.name + "!!",
					actor.name + " misses!"
				]
		DEFEND:
			actor.defend()
			text = [actor.name + " defends!!"]
		_:
			pass

	if !text.is_empty():
		_dialogue_box.add_text(text)
		if auto_advance_text:
			for _i in range(text.size()):
				await get_tree().create_timer(DEFAULT_WAIT_TIME).timeout
				_dialogue_box.advance()
		else:
			await _dialogue_box.closed
		
	if !target:
		end_state = DEFEAT if target_is_player else VICTORY
		
		var targets: Array = Data.party if target_is_player else enemies
		for battle_actor: BattleActor in targets:
			if battle_actor.hp > 0:
				end_state = -1
				break
		
		if end_state in [VICTORY, DEFEAT]:
			event_queue.clear()
			return

func run_through_event_queue() -> void:
	for i in range(event_queue.size()):
		if event_queue.is_empty():
			# Needed beacuse run_event clears event_queue if there are no valid targets left
			break
		
		var event: Array = event_queue[i]
		await run_event(event[ACTOR], event[ACTION_TYPE], event[TARGET])
	
	match end_state:
		VICTORY:
			_dialogue_box.add_text([
			"The party receives " + str(xp_gained) + " XP!",
			"The party receives " + str(gold_gained) + " gold!",
			# TODO item drops here
			])
			await _dialogue_box.closed
			
			for player: BattleActor in Data.party:
				player.xp += xp_gained / Data.party.size()
				player.gold += gold_gained / Data.party.size()
			
			#await debug_reload()
			queue_free()
		DEFEAT:
			_dialogue_box.add_text(["The party loses the will to continue :("])
			await _dialogue_box.closed
			#await debug_reload()
			queue_free()
	
	# Resets defending state
	for player in Data.party:
		player.is_defending = false
	
	# Clears queue and focus on options menu
	event_queue.clear()
	
	# Create animation of menus going up/down
	animate_box(_dialogue_box, true, 0)
	_dialogue_box.hide()
	animate_box(_bottom, false, 0)
	
	# Restart turns at first player
	next_player()

func next_player(dir: int = 1) -> bool:
	if !is_equal_approx(abs(dir), 1.0):
		print("Error, next_player dir must be 1 or -1")
		return false
	
	# Disable highlight on old player
	_player_info_cards[current_player_index].highlight(false)
	
	# Finds a valid player
	while current_player_index >= -1 and current_player_index < Data.party.size()-1:
		# If not last player, goes to next
		current_player_index += dir
	
		var player: BattleActor = Data.party[current_player_index]
		if player.hp > 0:
			_options_menu.focus_button()
			_player_info_cards[current_player_index].highlight(true)
			return true
	
	# No valid player found
	current_player_index = -1
	return false

func _on_menu_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			current_action = ATTACK
			_enemies_menu.focus_button()
		"Defend":
			current_action = DEFEND
			add_event(Data.party[current_player_index], current_action, null)
			if !next_player():
				enemies_turn()
		_:
			pass

func _on_enemies_menu_button_pressed(enemy_button: Enemy_Button) -> void:
	add_event(Data.party[current_player_index], current_action, enemy_button.battle_actor)
	if !next_player():
		enemies_turn()

func _on_player_hp_changed(_hp: int, value_changed: int) -> void:
	if value_changed < 0:
		_screen_shake.shake()
		Util.screen_flash(self, "player_is_hit", true)
		
func _on_enemy_button_defeated(battle_actor: BattleActor) -> void:
	xp_gained += battle_actor.xp
	gold_gained += battle_actor.gold
	enemies.erase(battle_actor)
