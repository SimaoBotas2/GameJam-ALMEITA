extends Area2D

@export_multiline var interaction_message: String = "Placeholder: interaction completed!"

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_label: Label = $InteractionLabel

func _ready() -> void:
	add_to_group("interaction_object")
	interaction_label.visible = false

func show_prompt() -> void:
	interaction_label.visible = true

func hide_prompt() -> void:
	interaction_label.visible = false

func interact() -> void:
	print(interaction_message)
	if sprite != null:
		sprite.modulate = Color(0.3, 1.0, 0.3, 1.0)
