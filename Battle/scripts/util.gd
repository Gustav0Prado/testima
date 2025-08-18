extends Node

const SCREEN_FLASH: PackedScene = preload("res://Battle/scenes/screen_flash.tscn")

func screen_flash(node: Node, animation: String) -> void:
	var inst: ScreenFlash = SCREEN_FLASH.instantiate()
	if node.owner == null:
		node.add_child(inst)
	else:
		node.owner.add_child(inst)
	inst.play(animation)

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
