class_name Menu extends Container

@export var focus_on_start: bool = false
@export var disable_focus_on_exit: bool = true

var index: int = 0

@onready var _boxes: Array = get_children()

var _buttons: Array

signal button_focused(button: BaseButton)
signal button_pressed(button: BaseButton)

func _ready() -> void:
	# Get all buttons
	if _boxes.size() <= 2:
		for b: Object in _boxes[0].get_children():
			_buttons.append(b)
		for b: Object in _boxes[1].get_children():
			_buttons.append(b)
	else:
		_buttons = _boxes
	
	# Bind buttons to functions and signals
	for button in _buttons:
		button.focus_entered.connect(_on_Button_focused.bind(button))
		button.focus_exited.connect(_on_Button_focus_exited.bind(button))
		button.pressed.connect(_on_Button_pressed.bind(button))
		button.tree_exiting.connect(_on_Button_tree_exited.bind(button))
		
	if focus_on_start:
		focus_button()
	elif disable_focus_on_exit:
		set_buttons_focus_mode(FOCUS_NONE)

func set_buttons_focus_mode(mode: int) -> void:
	for button in _buttons:
		button.focus_mode = mode

func connect_buttons_to_object(target: Object, _name: String = name) -> void:
	var callable = Callable()
	callable = Callable(target, "_on_" + _name + "_focused")
	button_focused.connect(callable)
	callable = Callable(target, "_on_" + _name + "_pressed")
	button_pressed.connect(callable)

func focus_button(n: int = index) -> void:
	if disable_focus_on_exit:
		set_buttons_focus_mode(FOCUS_ALL)
	
	index = clampi(n, 0, _buttons.size()-1)
	_buttons[index].grab_focus()

func get_buttons() -> Array:
	return self._buttons

func _on_Button_focused(button: BaseButton) -> void:
	emit_signal("button_focused", button)
	index = button.get_index()
	
func _on_Button_pressed(button: BaseButton) -> void:
	emit_signal("button_pressed", button)
	
func _on_Button_focus_exited(_button: BaseButton) -> void:
	await get_tree().process_frame
	if disable_focus_on_exit and not get_viewport().gui_get_focus_owner() in _buttons:
		set_buttons_focus_mode(FOCUS_NONE)
		
func _on_Button_tree_exited(button: BaseButton) -> void:
	_buttons.remove_at(button.get_index())
