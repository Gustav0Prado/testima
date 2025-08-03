class_name Menu extends Container

var index: int = 0

@onready var _boxes: Array = get_children()

var _buttons: Array

signal button_focused(button: BaseButton)
signal button_pressed(button: BaseButton)

func _ready() -> void:
	# Get buttons from both vbox children
	for b in _boxes[0].get_children():
		_buttons.append(b)
	for b in _boxes[1].get_children():
		_buttons.append(b)
	
	print(_buttons)
	
	# Bind buttons to functions and signals
	for button in _buttons:
		button.focus_entered.connect(_on_Button_focused.bind(button))
		button.pressed.connect(_on_Button_pressed.bind(button))

func connect_buttons_to_object(target: Object, _name: String = name) -> void:
	var callable = Callable()
	callable = Callable(target, "_on_" + _name + "_focused")
	button_focused.connect(callable)
	callable = Callable(target, "_on_" + _name + "_pressed")
	button_pressed.connect(callable)

func focus_button(n: int = index) -> void:
	index = n
	_buttons[n].grab_focus()

func _on_Button_focused(button: BaseButton) -> void:
	emit_signal("button_focused", button)
	
func _on_Button_pressed(button: BaseButton) -> void:
	emit_signal("button_pressed", button)
