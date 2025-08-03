extends Control

enum {
	ATTACK,
	DEFEND,
}

@onready var _enemies_menu: Menu = $EnemiesMenu
@onready var _options_menu: Menu = $Menu/Options/Menu

var event_queue: Array = []

func _ready() -> void:
	# Removes mouse input from the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Connects buttons to this object
	_enemies_menu.connect_buttons_to_object(self, "enemy_button")
	_options_menu.connect_buttons_to_object(self, "options_button")
	
	# Starts on options menu first option 
	_options_menu.focus_button()

#func _on_menu_button_focused(button: BaseButton) -> void:
	#print(button.text)

func add_event(actor: Object, type: int, target: Object) -> void:
	pass

func run_event() -> void:
	pass

func _on_menu_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			_enemies_menu.focus_button()
		_:
			pass

func _on_enemies_menu_button_pressed(enemy_button: Enemy_Button) -> void:
	enemy_button.battle_actor.heal_hurt(-1)
	_options_menu.focus_button()
