extends "res://scripts/objects/repeatable_interactable.gd"

var weight: int = 0

func get_player() -> Node:
	return get_tree().get_first_node_in_group("player")

func current_books() -> int:
	var player = get_player()
	return player.get_inventory_count("Book")

func get_prompt_text() -> String:
	var player = get_player()
	if player == null:
		return ""

	if weight == 3:
		var arm = player.get_inventory_count("Arm")
		if arm > 0:
			return "Press E to place the arm"
		return ""

	if current_books() > 1:
		return "Press E to place the books"
	elif current_books() == 1:
		return "Press E to place the book"

	return ""

func update_weight(new_weight: int) -> void:
	weight = new_weight
	update_prompt_text()

func _on_interact() -> void:
	var player = get_player()
	if player == null:
		finish_interaction()
		return

	if weight == 3:
		var arm = player.get_inventory_count("Arm")
		if arm > 0:
			player.remove_from_inventory("Arm", 1)
			update_weight(4)
	else:
		var books_to_place := current_books()
		if books_to_place > 0:
			player.remove_from_inventory("Book", books_to_place)
			update_weight(weight + books_to_place)

	finish_interaction()
