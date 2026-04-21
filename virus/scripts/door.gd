extends "res://scripts/interaction_object.gd"

@onready var audio_player: AudioStreamPlayer2D = get_node_or_null("InteractionLabel/AudioStreamPlayer2D")

func _on_interact() -> void:
	var played_sound := false
	if audio_player != null and audio_player.stream != null:
		audio_player.play()
		played_sound = true

	if played_sound:
		await audio_player.finished
	get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
