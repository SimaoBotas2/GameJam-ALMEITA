extends "res://scripts/objects/single_use_interactable.gd"

# Classe base para itens que são recolhidos e adicionados ao inventário.
# Os filhos devem implementar o nome, a quantidade e, se quiserem, o som.

var audio_player: AudioStreamPlayer2D = null

func _ready() -> void:
	super._ready()
	audio_player = get_node_or_null("AudioStreamPlayer2D")

func get_item_name() -> String:
	return ""

func get_item_amount() -> int:
	return 1

func get_pickup_sound() -> AudioStream:
	return null

func _play_pickup_sound() -> void:
	var sound := get_pickup_sound()
	if audio_player == null or sound == null:
		return

	audio_player.stream = sound
	audio_player.play()
	await audio_player.finished

func _on_interact() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("add_to_inventory"):
		player.add_to_inventory(get_item_name(), get_item_amount())

	_play_pickup_sound()
	queue_free()