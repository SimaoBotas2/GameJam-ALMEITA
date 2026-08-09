extends "res://scripts/objects/single_use_interactable.gd"

@export var used_texture: Texture2D
# Deixamos vazio por default porque nem todos os botões mudam de sala (alguns só
# fazem outra coisa). Escolhe-se a cena no Inspector para dar para reusar este
# botão em qualquer sítio, sem ter de copiar/alterar o script.
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
