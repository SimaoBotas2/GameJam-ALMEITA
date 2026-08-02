extends Area2D

@export var painting_title: String = "Painting"
@export var closeup_texture: Texture2D
@export var prompt_offset: Vector2 = Vector2(0, -64)

@export var frame_display_size: Vector2 = Vector2(70, 94)
@export var canvas_display_size: Vector2 = Vector2(58, 82)

const PaintingInspectorScene = preload("res://scenes/ui/painting_inspector.tscn")

var is_open: bool = false

@onready var frame_sprite: Sprite2D = $FrameSprite
@onready var canvas_sprite: Sprite2D = $CanvasSprite
@onready var interaction_label: Label = $InteractionLabel

func _ready() -> void:
	add_to_group("interaction_object")
	interaction_label.visible = false
	interaction_label.top_level = true
	interaction_label.z_as_relative = false
	interaction_label.z_index = 1000

	_fit_sprite_to_box(frame_sprite, frame_display_size)
	_fit_sprite_to_box(canvas_sprite, canvas_display_size)

## Scales a sprite so its texture fits entirely inside the painting, was getting bigger textures before.
func _fit_sprite_to_box(sprite: Sprite2D, target_size: Vector2) -> void:
	if sprite == null or sprite.texture == null:
		return

	var texture_size := sprite.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var scale_factor = min(target_size.x / texture_size.x, target_size.y / texture_size.y)
	sprite.scale = Vector2(scale_factor, scale_factor)

func show_prompt() -> void:
	if not is_open:
		interaction_label.visible = true

func hide_prompt() -> void:
	interaction_label.visible = false

func interact() -> void:
	if is_open:
		return

	is_open = true
	hide_prompt()

	var texture_to_show := closeup_texture
	if texture_to_show == null and canvas_sprite != null and canvas_sprite.texture != null:
		texture_to_show = canvas_sprite.texture
	if texture_to_show == null and frame_sprite != null:
		texture_to_show = frame_sprite.texture

	var player = get_tree().get_first_node_in_group("player")

	var inspector = PaintingInspectorScene.instantiate()
	get_tree().current_scene.add_child(inspector)
	inspector.closed.connect(_on_inspector_closed)
	inspector.open(texture_to_show, painting_title, player)

func _on_inspector_closed() -> void:
	is_open = false
	show_prompt()
