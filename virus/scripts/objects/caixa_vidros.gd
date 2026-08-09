extends "res://scripts/objects/single_use_interactable.gd"

@export var release_chain_on_use: bool = false
@export var used_texture: Texture2D
# Se não ficar vazio, muda a skin da personagem para esta ao usar (ex: "after_glass").
@export var skin_on_use: String = ""


@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var audio_player: AudioStreamPlayer2D = get_node_or_null("InteractionLabel/AudioStreamPlayer2D")

func _on_interact() -> void:
	if audio_player != null and audio_player.stream != null:
		audio_player.play()

	if sprite != null:
		if used_texture != null:
			sprite.texture = used_texture
		else:
			sprite.visible = false

	var player = get_tree().get_first_node_in_group("player")

	if release_chain_on_use:
		if player != null and player.has_method("release_chain"):
			player.release_chain()

	if not skin_on_use.is_empty():
		if player != null and player.has_method("set_skin"):
			player.set_skin(skin_on_use)
