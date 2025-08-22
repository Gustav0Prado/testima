extends Node

const SCREEN_FLASH: PackedScene = preload("res://Battle/scenes/screen_flash.tscn")

enum Facing {
	RIGHT,
	DOWN,
	LEFT,
	UP,
}

func screen_flash(node: Node, animation: String, use_owner: bool) -> ScreenFlash:
	var inst: ScreenFlash = SCREEN_FLASH.instantiate()
	if !use_owner or node.owner == null:
		node.add_child(inst)
	else:
		node.owner.add_child(inst)
	inst.play(animation)
	return inst

func choose(array: Array):
	return array[randi() % array.size()]

func choose_weighted(choices: Array):
	# choices = [variant, chance(int), variant, chance(int)...]
	var n: int = 0
	var choices_size: int = choices.size()
	for i in range(1, choices_size, 2):
		if choices[i] <= 0:
			continue
		n += choices[i]
	
	n = randi() % int(n) # this was prev not int()
	for i in range(1, choices_size, 2):
		if choices[i] <= 0:
			continue
		n -= choices[i]
		if n < 0:
			return choices[i - 1]
	return choices[0]

func add_with_random_spread(value: int, spread: int) -> int:
	return value + randi_range(-spread, spread)
	
func get_four_directions_vector(diagonal_allowed: bool) -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	elif Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	if diagonal_allowed or is_zero_approx(direction.x):
		if Input.is_action_pressed("ui_up"):
			direction.y -= 1
		elif Input.is_action_pressed("ui_down"):
			direction.y += 1
	
	return direction

func convert_vector2_to_int(dir: Vector2) -> int:
	if dir.y < 0:
		return Facing.UP
	elif dir.y > 0:
		return Facing.DOWN
	elif dir.x < 0:
		return Facing.LEFT
	elif dir.x > 0:
		return Facing.RIGHT
	else:
		return Facing.DOWN # default
	
func convert_vector2_to_string(dir: Vector2) -> String:
	var value: int = convert_vector2_to_int(dir)
	var keys: Array = Facing.keys()
	for key in keys:
		if Facing[key] == value:
			return key
	return ""
