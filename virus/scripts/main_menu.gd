extends Control

@onready var play_button = $TextureButton_Play
@onready var options_button = $TextureButton_Options
# Certifica-te que tens um nó chamado "OptionsPopup" na tua cena!
@onready var options_popup = $OptionsPopup 

# Substitui o que está entre aspas pelo "Copy Path" da tua imagem real
var cursor_sprite = preload("res://assets/seringe_cur.png")

func _ready() -> void:
	# Só tenta esconder se o nó realmente existir para evitar crashes
	if options_popup != null:
		options_popup.hide()
		
	Input.set_custom_mouse_cursor(cursor_sprite)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_texture_button_play_pressed():
	# Nome do ficheiro corrigido de acordo com a tua pasta scenes
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
	
func _on_texture_button_options_pressed():
	if options_popup != null:
		options_popup.show()
		options_button.hide()


func _on_button_pressed() -> void:
	options_popup.hide()
