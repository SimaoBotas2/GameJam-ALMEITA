extends Control

@onready var icon: TextureRect = $Background/Icon
@onready var amount_label: Label = $Background/Amount

var item_name: String = ""

func set_item(new_item_name: String, amount: int) -> void:
	item_name = new_item_name

	var texture_path := "res://assets/inventory/%s.png" % item_name
	if ResourceLoader.exists(texture_path):
		icon.texture = load(texture_path)
		
	set_amount(amount)

func set_amount(amount: int) -> void:
	amount_label.text = "x%d" % amount
	amount_label.visible = amount > 1
