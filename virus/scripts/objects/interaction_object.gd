extends Area2D

@export var prompt_offset: Vector2 = Vector2(0, -64)
@export var prompt_margin: Vector2 = Vector2(12, 12)

var was_used: bool = false

@onready var interaction_label: Label = $InteractionLabel

func _ready() -> void:
	z_index = 0
	add_to_group("interaction_object")
	interaction_label.visible = false
	interaction_label.top_level = true
	interaction_label.z_as_relative = false
	interaction_label.z_index = 1000

func show_prompt() -> void:
	if not was_used:
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

func interact() -> void:
	if was_used:
		return

	was_used = true
	interaction_label.visible = false
	monitoring = false
	monitorable = false
	collision_layer = 0

	_on_interact()

func _on_interact() -> void:
	pass
