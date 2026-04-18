extends CharacterBody2D

@export var move_speed : float = 350
@export var starting_direction: Vector2 = Vector2.ZERO
@export var scene_limit_margin: Vector2 = Vector2(8, 12)

var current_interaction_object: Area2D = null

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var camera: Camera2D = $Camera2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D

func _ready():
	animation_tree.active = true
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_direction * move_speed
	move_and_slide()
	clamp_to_scene_limits()
	
	update_animation_parameters(input_direction)
	pick_new_state()
	handle_interaction()

func update_animation_parameters(move_input: Vector2):
	if move_input != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", move_input)

func pick_new_state():
	if velocity != Vector2.ZERO:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func clamp_to_scene_limits() -> void:
	var half_size := Vector2.ZERO
	if body_collision.shape is RectangleShape2D:
		var rect := body_collision.shape as RectangleShape2D
		half_size = rect.size * 0.5

	var min_x = camera.limit_left + scene_limit_margin.x - body_collision.position.x + half_size.x
	var max_x = camera.limit_right - scene_limit_margin.x - body_collision.position.x - half_size.x
	var min_y = camera.limit_top + scene_limit_margin.y - body_collision.position.y + half_size.y
	var max_y = camera.limit_bottom - scene_limit_margin.y - body_collision.position.y - half_size.y

	global_position.x = clampf(global_position.x, min_x, max_x)
	global_position.y = clampf(global_position.y, min_y, max_y)


# Interaction handling

func handle_interaction() -> void:
	if current_interaction_object != null and Input.is_action_just_pressed("interact"):
		if current_interaction_object.has_method("interact"):
			current_interaction_object.interact()
		else:
			print("Placeholder: interacting with ", current_interaction_object.name)

func _on_interaction_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("interaction_object"):
		current_interaction_object = area
		if area.has_method("show_prompt"):
			area.show_prompt()

func _on_interaction_detector_area_exited(area: Area2D) -> void:
	if area == current_interaction_object:
		if area.has_method("hide_prompt"):
			area.hide_prompt()
		current_interaction_object = null
