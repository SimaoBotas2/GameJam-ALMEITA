extends Node

const LOOP_MUSIC = preload("res://assets/sound/loop.wav")

signal item_added(item_name: String, new_amount: int) # sinal emitido quando um item é adicionado ao inventário

var chain_released: bool = false
# Guarda a skin atual da personagem para não se perder ao mudar de sala
# (cada sala cria uma personagem nova, começaria sempre em "default" senão).
var current_skin: String = "default"
var inventory: Dictionary = {} #inventário do jogador (nome do item -> quantidade)
var music_player: AudioStreamPlayer

func add_item(item_name: String, amount: int = 1) -> void:
	if amount <= 0:
		return

	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount
	item_added.emit(item_name, inventory[item_name])

func remove_item(item_name: String, amount: int = 1) -> bool:
	if not inventory.has(item_name):
		return false

	inventory[item_name] = max(0, inventory[item_name] - amount)
	if inventory[item_name] <= 0:
		inventory.erase(item_name)

	return true

func get_item_count(item_name: String) -> int:
	return inventory.get(item_name, 0)

func clear_inventory() -> void:
	inventory.clear()

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.stream = LOOP_MUSIC
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)

func start_music() -> void:
	if music_player != null and not music_player.playing:
		music_player.play()

func _on_music_finished() -> void:
	if music_player != null:
		music_player.play()
