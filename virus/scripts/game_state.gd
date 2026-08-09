extends Node

const LOOP_MUSIC = preload("res://assets/sound/loop.wav")

var chain_released: bool = false
# Guarda a skin atual da personagem para não se perder ao mudar de sala
# (cada sala cria uma personagem nova, começaria sempre em "default" senão).
var current_skin: String = "default"
var music_player: AudioStreamPlayer

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
