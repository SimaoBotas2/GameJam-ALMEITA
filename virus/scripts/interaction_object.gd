extends Area2D

@export_multiline var interaction_message: String = "Placeholder: interação feita!"

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("interaction_object")

func interact() -> void:
	print(interaction_message)
	if sprite != null:
		sprite.modulate = Color(0.3, 1.0, 0.3, 1.0)
