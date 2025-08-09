class_name DialogueBox extends NinePatchRect

signal closed()

var lines: Array = []

@onready var _dialogue: Label = $MarginContainer/Label

@export var handleInput: bool = true

func _ready() -> void:
	clear()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance()
	elif event.is_action_pressed("ui_cancel"):
		advance()
	else: return

func clear() -> void:
	_dialogue.text = ""
	hide()
	set_process_input(false)
	emit_signal("closed")
	get_viewport().set_input_as_handled()
	
func advance() -> void:
	if !lines:
		clear()
		return
	
	if _dialogue.text != "":
		_dialogue.text += "\n"
	else:
		show()
		set_process_input(handleInput)
	
	_dialogue.text += lines.pop_front()
	
func add_text(text: Array) -> void:
	if text:
		lines.append_array(text)
		advance()
