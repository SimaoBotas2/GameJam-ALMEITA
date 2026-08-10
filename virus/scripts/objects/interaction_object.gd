extends StaticBody2D

# Base de qualquer coisa com que a personagem possa interagir (porta, botão,
# quadro, etc). A raiz é um StaticBody2D para ser sólida por omissão — a
# deteção de "a personagem está perto para interagir" fica num Area2D filho
# (InteractionZone), porque só Area2D gera sinais de sobreposição com o
# detetor da personagem. Não decide se dá para interagir mais que uma vez,
# isso fica para single_use_interactable.gd ou repeatable_interactable.gd,
# que estendem isto.

@export var prompt_offset: Vector2 = Vector2(0, -64)
@export var prompt_margin: Vector2 = Vector2(12, 12)

# Liga/desliga a colisão física deste objeto. Objetos decorativos (ex: um
# quadro na parede, um item para apanhar do chão) podem pôr isto a false.
@export var is_solid: bool = true

@onready var interaction_zone: Area2D = $InteractionZone
@onready var interaction_label: Label = $InteractionZone/InteractionLabel
@onready var solid_collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	z_index = 0
	interaction_zone.add_to_group("interaction_object")
	interaction_label.visible = false
	interaction_label.top_level = true
	interaction_label.z_as_relative = false
	interaction_label.z_index = 1000

	if solid_collision != null:
		solid_collision.disabled = not is_solid

func get_prompt_text() -> String:
	return interaction_label.text

func update_prompt_text() -> void:
	interaction_label.text = get_prompt_text()

func show_prompt() -> void:
	update_prompt_text()
	interaction_label.visible = true
	clamp_prompt_to_scene()

func hide_prompt() -> void:
	interaction_label.visible = false

func clamp_prompt_to_scene() -> void:
	var camera := get_viewport().get_camera_2d()
	var label_size := interaction_label.size
	if label_size == Vector2.ZERO:
		label_size = Vector2(
			interaction_label.offset_right - interaction_label.offset_left,
			interaction_label.offset_bottom - interaction_label.offset_top
		)

	var desired_position = global_position + Vector2(prompt_offset.x - label_size.x * 0.5, prompt_offset.y)

	if camera == null:
		interaction_label.global_position = desired_position
		return

	var min_x = camera.limit_left + prompt_margin.x
	var max_x = camera.limit_right - prompt_margin.x - label_size.x
	var min_y = camera.limit_top + prompt_margin.y
	var max_y = camera.limit_bottom - prompt_margin.y - label_size.y

	if desired_position.y < min_y:
		desired_position.y = global_position.y + 24

	interaction_label.global_position = Vector2(
		clampf(desired_position.x, min_x, max_x),
		clampf(desired_position.y, min_y, max_y)
	)

# Cada subclasse define as regras de quando é que se pode interagir outra vez.
func interact() -> void:
	pass

# É só isto que um objeto novo precisa de implementar.
func _on_interact() -> void:
	pass
