extends "res://scripts/objects/single_use_interactable.gd"

# Dá para escolher a cena no Inspector, para podermos copiar esta porta e usar em qualquer sala.
@export_file("*.tscn") var next_scene_path: String = "res://scenes/levels/level_2.tscn"

@onready var audio_player: AudioStreamPlayer2D = get_node_or_null("InteractionZone/InteractionLabel/AudioStreamPlayer2D")

func _on_interact() -> void:
	var played_sound := false
	if audio_player != null and audio_player.stream != null:
		audio_player.play()
		played_sound = true

	if played_sound:
		await audio_player.finished

	if not next_scene_path.is_empty():
		get_tree().change_scene_to_file(next_scene_path)
