extends CanvasLayer

const SLOT_SCENE := preload("res://scenes/ui/inventory_slot.tscn")

@onready var slot_container: HBoxContainer = $BottomBar/Margin/HBoxContainer

var slots: Dictionary = {} # item_name -> slot instance

func _ready() -> void:
	GameState.item_added.connect(_on_item_added)
	_populate_from_existing_inventory()

func _populate_from_existing_inventory() -> void:
	for item_name in GameState.inventory:
		_on_item_added(item_name, GameState.inventory[item_name])

func _on_item_added(item_name: String, new_amount: int) -> void:
	if slots.has(item_name):
		slots[item_name].set_amount(new_amount)
		return

	var slot := SLOT_SCENE.instantiate()
	slot_container.add_child(slot)
	slot.set_item(item_name, new_amount)
	slots[item_name] = slot
