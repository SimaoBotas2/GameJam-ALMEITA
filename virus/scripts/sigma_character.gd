extends CharacterBody2D

@export var move_speed : float = 350
@export var starting_direction: Vector2 = Vector2.ZERO
@export var scene_limit_margin: Vector2 = Vector2(8, 12)
@export var chain_max_distance: float = 150.0
@export var chain_anchor_offset: Vector2 = Vector2(80, 150)
@export var chain_attach_offset: Vector2 = Vector2(0, 150)

var current_interaction_object: Area2D = null
var chain_anchor_global_position: Vector2
var chain_released: bool = false
var interaction_locked: bool = false

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var camera: Camera2D = $Camera2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D
@onready var chain_sprite: Sprite2D = $ChainSprite
@onready var footsteps_player: AudioStreamPlayer = $FootstepsPlayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	add_to_group("player")
	animation_tree.active = true
	chain_anchor_global_position = global_position + chain_anchor_offset
	chain_sprite.top_level = true

	var game_state = get_node_or_null("/root/GameState")
	if game_state != null:
		if game_state.chain_released:
			chain_released = true
		var current_scene := get_tree().current_scene
		if current_scene != null and current_scene.name == "level_1" and game_state.has_method("start_music"):
			game_state.start_music()

	if footsteps_player != null and footsteps_player.stream is AudioStreamWAV:
		var footsteps_stream := footsteps_player.stream as AudioStreamWAV
		footsteps_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	update_chain_visual()
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_direction * move_speed
	move_and_slide()
	clamp_to_chain_limits()
	clamp_to_scene_limits()
	update_chain_visual()
	
	update_animation_parameters(input_direction)
	pick_new_state()
	update_footsteps_audio()
	handle_interaction()

func update_animation_parameters(move_input: Vector2):
	if move_input != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", move_input)

	if move_input.x < 0:
		sprite.flip_h = true
	elif move_input.x > 0:
		sprite.flip_h = false

func pick_new_state():
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

func clamp_to_chain_limits() -> void:
	if chain_released:
		return

	var player_chain_point = global_position + chain_attach_offset
	var tether_vector = player_chain_point - chain_anchor_global_position
	if tether_vector.length() > chain_max_distance:
		global_position = chain_anchor_global_position + tether_vector.normalized() * chain_max_distance - chain_attach_offset

func update_chain_visual() -> void:
	if chain_sprite == null:
		return

	if chain_released:
		chain_sprite.visible = false
		return

	if chain_sprite.texture == null:
		return

	chain_sprite.visible = true

	var player_chain_point = global_position + chain_attach_offset
	var distance = chain_anchor_global_position.distance_to(player_chain_point)
	chain_sprite.global_position = (chain_anchor_global_position + player_chain_point) * 0.5
	chain_sprite.rotation = chain_anchor_global_position.angle_to_point(player_chain_point) + PI * 0.5

	var texture_height = float(chain_sprite.texture.get_height())
	if texture_height > 0.0:
		chain_sprite.scale = Vector2(0.35, max(distance / texture_height, 0.08))

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

func release_chain() -> void:
	chain_released = true

	var game_state = get_node_or_null("/root/GameState")
	if game_state != null:
		game_state.chain_released = true

	update_chain_visual()


# Interaction handling

func handle_interaction() -> void:
	if interaction_locked:
		return

	if current_interaction_object != null and Input.is_action_just_pressed("interact"):
		if current_interaction_object.has_method("interact"):
			current_interaction_object.interact()
		else:
			print("Placeholder: interacting with ", current_interaction_object.name)

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
