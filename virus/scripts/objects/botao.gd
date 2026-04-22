extends "res://scripts/objects/interaction_object.gd"

@export var used_texture: Texture2D
@export_file("*.tscn") var next_scene_path: String = ""

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _on_interact() -> void:
	if sprite != null:
		if used_texture != null:
			sprite.texture = used_texture
		else:
			sprite.visible = false

	if not next_scene_path.is_empty():
		get_tree().change_scene_to_file(next_scene_path)
