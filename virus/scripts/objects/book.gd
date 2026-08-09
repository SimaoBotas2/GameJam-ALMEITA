extends "res://scripts/objects/consumable.gd"

func get_pickup_sound() -> AudioStream:
	return null # trocar quando houver som para o item (preload(path))

func get_item_name() -> String:
	return "Book"

func get_item_amount() -> int:
	return 1
