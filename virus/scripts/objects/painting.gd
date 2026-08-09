extends "res://scripts/objects/interaction_object.gd"

# Isto é o comportamento de um quadro que se pode inspecionar de perto.
# Herdamos do interaction_object para aproveitar o setup do label e do grupo
# "interaction_object", mas o interact() é todo nosso: a base foi feita para
# coisas de uso único (porta, botão) que se desligam depois do primeiro clique,
# e aqui o quadro tem de poder ser aberto e fechado as vezes que quisermos.

@export var painting_title: String = "Painting"
@export var closeup_texture: Texture2D

@export var frame_display_size: Vector2 = Vector2(70, 94)
@export var canvas_display_size: Vector2 = Vector2(58, 82)

const PaintingInspectorScene = preload("res://scenes/ui/painting_inspector.tscn")

var is_open: bool = false

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

# Sobrepomos só o show_prompt da base para não mostrar a dica enquanto o
# quadro já está aberto (a base guarda-se com "was_used", nós com "is_open").
# hide_prompt() não precisa de override, o da base já serve na mesma.
func show_prompt() -> void:
	if not is_open:
		super.show_prompt()

# Este interact() substitui por completo o da base (não chamamos super.interact()),
# porque não queremos desligar a colisão do quadro depois de usar uma vez.
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
