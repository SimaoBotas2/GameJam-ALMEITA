extends "res://scripts/interaction_object.gd"

@export var release_chain_on_use: bool = false
@export var used_texture: Texture2D


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

	if release_chain_on_use:
		var player = get_tree().get_first_node_in_group("player")
		if player != null and player.has_method("release_chain"):
			player.release_chain()
