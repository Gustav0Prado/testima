extends Control

@onready var _options_menu: Menu = $Menu/Options/Menu

func _ready() -> void:
	# Removes mouse input from the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Connects buttons to this object
	_options_menu.connect_buttons_to_object(self, "options_button")
	
	# Starts menu on first option 
	_options_menu.focus_button(0)


func _on_menu_button_focused(button: BaseButton) -> void:
	print(button.text)


func _on_menu_button_pressed(button: BaseButton) -> void:
	print(button.text)
