extends "res://scripts/objects/repeatable_interactable.gd"

# O quadro que se pode inspecionar de perto, quantas vezes quiseres. Herda do
# repeatable_interactable, que já trata de bloquear novas interações enquanto
# o popup está aberto, aqui só tratamos de abrir o popup e, quando ele fecha,
# avisar a base (finish_interaction()) que já se pode interagir outra vez.

@export var painting_title: String = "Painting"
@export var closeup_texture: Texture2D

@export var frame_display_size: Vector2 = Vector2(70, 94)
@export var canvas_display_size: Vector2 = Vector2(58, 82)

const PaintingInspectorScene = preload("res://scenes/ui/painting_inspector.tscn")

@onready var frame_sprite: Sprite2D = $FrameSprite
@onready var canvas_sprite: Sprite2D = $CanvasSprite

func _ready() -> void:
	super._ready()
	_fit_sprite_to_box(frame_sprite, frame_display_size)
	_fit_sprite_to_box(canvas_sprite, canvas_display_size)

## Encolhe/aumenta a sprite para a textura caber toda dentro do tamanho pedido,
## sem esticar (a imagem entrava sempre maior do que o quadro antes disto).
func _fit_sprite_to_box(sprite: Sprite2D, target_size: Vector2) -> void:
	if sprite == null or sprite.texture == null:
		return

	var texture_size := sprite.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var scale_factor = min(target_size.x / texture_size.x, target_size.y / texture_size.y)
	sprite.scale = Vector2(scale_factor, scale_factor)

func _on_interact() -> void:
	var texture_to_show := closeup_texture
	if texture_to_show == null and canvas_sprite != null and canvas_sprite.texture != null:
		texture_to_show = canvas_sprite.texture
	if texture_to_show == null and frame_sprite != null:
		texture_to_show = frame_sprite.texture

	var player = get_tree().get_first_node_in_group("player")

	var inspector = PaintingInspectorScene.instantiate()
	get_tree().current_scene.add_child(inspector)
	inspector.closed.connect(finish_interaction)
	inspector.open_painting(texture_to_show, painting_title, player)
