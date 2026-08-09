extends Control

@onready var play_button = $TextureButton_Play
@onready var options_button = $TextureButton_Options
# Tem de haver um nó chamado "OptionsPopup" nesta cena, se não isto rebenta.
@onready var options_popup = $OptionsPopup

# Caminho da imagem do cursor personalizado (o "Copy Path" no FileSystem).
var cursor_sprite = preload("res://assets/menu/seringe_cur.png")
@export_file("*.tscn") var next_scene_path: String = "res://scenes/levels/room_1.tscn"

func _ready() -> void:
	$AudioStreamPlayer.play(0.9)
	# Só escondemos se o popup existir mesmo, para não rebentar por causa disto
	if options_popup != null:
		options_popup.hide()

	Input.set_custom_mouse_cursor(cursor_sprite)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_texture_button_play_pressed():
	$SFXPlayer.play(0.2)
	await get_tree().create_timer(0.23).timeout
	$SFXPlayer.stop()
	get_tree().change_scene_to_file(next_scene_path)
	
func _on_texture_button_options_pressed():
	if options_popup != null:
		$SFXPlayer.play(0.2)
		await get_tree().create_timer(0.23).timeout
		$SFXPlayer.stop()
		options_popup.show()
		options_button.hide()


func _on_button_pressed() -> void:
	$SFXPlayer.play(0.2)
	await get_tree().create_timer(0.23).timeout
	$SFXPlayer.stop()
	options_popup.hide()
