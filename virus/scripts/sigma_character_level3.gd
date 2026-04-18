extends CharacterBody2D

@export var move_speed : float = 350
@export var starting_direction: Vector2 = Vector2.ZERO
@export var scene_limit_margin: Vector2 = Vector2(8, 12)

var current_interaction_object: Area2D = null
var interaction_locked: bool = false

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var camera: Camera2D = $Camera2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D
@onready var footsteps_player: AudioStreamPlayer = $FootstepsPlayer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	add_to_group("player")
	animation_tree.active = true

	if footsteps_player != null and footsteps_player.stream is AudioStreamWAV:
		var footsteps_stream := footsteps_player.stream as AudioStreamWAV
		footsteps_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	update_animation_parameters(starting_direction)

func _physics_process(_delta: float) -> void:
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	velocity = input_direction * move_speed
	move_and_slide()
	clamp_to_scene_limits()

	update_animation_parameters(input_direction)
	pick_new_state()
	update_footsteps_audio()
	handle_interaction()

func update_animation_parameters(move_input: Vector2) -> void:
	if move_input != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", move_input)

	if move_input.x < 0:
		sprite.flip_h = true
	elif move_input.x > 0:
		sprite.flip_h = false

func pick_new_state() -> void:
	if velocity != Vector2.ZERO:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func update_footsteps_audio() -> void:
	if footsteps_player == null:
		return

	if velocity.length() > 0.0:
		if not footsteps_player.playing:
			footsteps_player.play()
	else:
		footsteps_player.stop()

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

func handle_interaction() -> void:
	if interaction_locked:
		return

	if current_interaction_object != null and Input.is_action_just_pressed("interact"):
		if current_interaction_object.has_method("interact"):
			current_interaction_object.interact()

func lock_interaction() -> void:
	interaction_locked = true
	if current_interaction_object != null and current_interaction_object.has_method("hide_prompt"):
		current_interaction_object.hide_prompt()

func unlock_interaction() -> void:
	interaction_locked = false
	if current_interaction_object != null and current_interaction_object.has_method("show_prompt"):
		current_interaction_object.show_prompt()

func _on_interaction_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("interaction_object"):
		current_interaction_object = area
		if not interaction_locked and area.has_method("show_prompt"):
			area.show_prompt()

func _on_interaction_detector_area_exited(area: Area2D) -> void:
	if area == current_interaction_object:
		if area.has_method("hide_prompt"):
			area.hide_prompt()
		current_interaction_object = null
