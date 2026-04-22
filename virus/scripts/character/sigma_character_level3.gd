extends BaseCharacter

@export var chain_max_distance: float = 150.0
@export var chain_anchor_offset: Vector2 = Vector2(80, 150)
@export var chain_attach_offset: Vector2 = Vector2(0, 150)

var chain_anchor_global_position: Vector2
var chain_released: bool = false

@onready var chain_sprite: Sprite2D = $ChainSprite

func _ready() -> void:
	z_index = 1
	super()
	chain_anchor_global_position = global_position + chain_anchor_offset
	chain_sprite.top_level = true

	var game_state = get_node_or_null("/root/GameState")
	if game_state != null:
		if game_state.chain_released:
			chain_released = true
		var current_scene := get_tree().current_scene
		if current_scene != null and current_scene.name == "level_1" and game_state.has_method("start_music"):
			game_state.start_music()

	update_chain_visual()

func _apply_movement_constraints() -> void:
	clamp_to_chain_limits()

func _post_physics_update() -> void:
	update_chain_visual()

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

func release_chain() -> void:
	chain_released = true

	var game_state = get_node_or_null("/root/GameState")
	if game_state != null:
		game_state.chain_released = true

	update_chain_visual()
