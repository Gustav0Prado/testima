class_name Danger extends Node

signal limit_reached()

@export var limit_base: int = 400
@export var enabled: bool = true
@export var show_debug_text: bool = true

@onready var _canvas_layer: CanvasLayer = $CanvasLayer
@onready var _debug_label: Label = $CanvasLayer/MarginContainer/Limit

var limit: int = 0

func _ready() -> void:
	set_limit()
	
	if show_debug_text:
		_canvas_layer.show()
	else:
		_canvas_layer.queue_free()
		
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		match event.keycode:
			KEY_D:
				enabled = !enabled
			KEY_E:
				_canvas_layer.visible = !_canvas_layer.visible
				
func set_limit() -> void:
	limit = randi_range(limit_base * 0.5, limit_base * 1.5)
	_debug_label.text = str(limit)
	
func countdown(amount: int = 1) -> void:
	if enabled:
		limit -= amount
		
		if limit <= 0:
			limit_reached.emit()
			set_limit()
		
		if show_debug_text:
			_debug_label.text = str(limit)
