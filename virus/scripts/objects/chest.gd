extends "res://scripts/objects/repeatable_interactable.gd"

@export var chest_title: String = "Insert Code Below"
@export var closeup_texture: Texture2D

@export var frame_display_size: Vector2 = Vector2(70, 94)
@export var canvas_display_size: Vector2 = Vector2(58, 82)

const chest_after : Texture2D = preload("res://assets/objects/chest/chest_open.png")
const ChestInspectorScene = preload("res://scenes/ui/chest_inspector.tscn")

@onready var is_chest_solved = false

# Preenchido de fora (ex: room_1.gd), com o código certo calculado a partir
# dos paintings sorteados nos quadros. Se ficar vazio, o chest_inspector usa
# o código por omissão dele próprio.
var expected_code: Array = []

func show_prompt() -> void:
	if not is_chest_solved:
		super.show_prompt()
 
func _on_chest_solved() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("release_chain"):
		player.release_chain()

#para mudar a textura, ir buscar o sprite e alterar.
	var sprite: Sprite2D = get_node("Sprite2D")
	if sprite != null:
		sprite.texture = chest_after
	
	is_chest_solved = true

func _ready() -> void:
	super._ready()

func _on_interact() -> void:
	
	if not is_chest_solved:
		var texture_to_show := closeup_texture
		if texture_to_show == null:
			texture_to_show = get_node("Sprite2D").texture

		var player = get_tree().get_first_node_in_group("player")

		var inspector = ChestInspectorScene.instantiate()
		if not expected_code.is_empty():
			inspector.chest_code = expected_code
		get_tree().current_scene.add_child(inspector)
		inspector.closed.connect(finish_interaction)
		inspector.solved.connect(_on_chest_solved)
		inspector.open_chest(texture_to_show, chest_title, player)
		
	
	
