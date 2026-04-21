extends Node2D

const INTRO_CLIPS = [
	preload("res://assets/sound/Jessie_Ken_1.1.wav"),
	preload("res://assets/sound/SIH_1.wav"),
	preload("res://assets/sound/Jessie_Ken_1.2.wav")
]

var intro_player: AudioStreamPlayer
var intro_started: bool = false

@onready var player = $SigmaCharacter

func _ready() -> void:
	intro_player = AudioStreamPlayer.new()
	intro_player.name = "IntroDialoguePlayer"
	add_child(intro_player)
	#play_intro_sequence()

#func play_intro_sequence() -> void:
	#if intro_started:
		#return
#
	#intro_started = true
#
	#if player != null and player.has_method("lock_interaction"):
		#player.lock_interaction()
#
	#for clip in INTRO_CLIPS:
		#if clip == null:
			#continue
		#intro_player.stream = clip
		#intro_player.play()
		#await intro_player.finished
#
	#if player != null and player.has_method("unlock_interaction"):
		#player.unlock_interaction()
