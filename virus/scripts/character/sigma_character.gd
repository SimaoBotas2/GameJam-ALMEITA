extends BaseCharacter

#Talvez mudar a lógica da corrente mais tarde se for necessária noutra sala.
#se for preciso adicioanr uma função pública para atualziar estes valores.

# Comprimento da Corrrente
@export var chain_max_distance: float = 350.0

# Offset calculado a partir do centro do spawn do Sih
@export var chain_anchor_offset: Vector2 = Vector2(0,150)

# Onde é que a corrente agarra a personagem (não é exatamente o centro dela,
# é este offset a partir da posição da personagem).
@export var chain_attach_offset: Vector2 = Vector2(0,150)

# Liga/desliga a mecânica toda da corrente. Por isto a false e o resto do código da corrente nem corre.
@export var has_chain: bool = true

# Posição no mundo do ponto fixo da corrente, calculada uma vez no _ready()
# a partir do chain_anchor_offset (só faz sentido se has_chain for true).
var chain_anchor_global_position: Vector2

# Fica true assim que a corrente é largada (via release_chain()) a partir
# daí a personagem deixa de estar limitada pela corrente.
var chain_released: bool = false

@onready var chain_sprite: Sprite2D = get_node_or_null("ChainSprite")

func _ready() -> void:
	super()
	if has_chain:
		chain_anchor_global_position = global_position + chain_anchor_offset
		chain_sprite.top_level = true

		var game_state = get_node_or_null("/root/GameState")
		if game_state != null and game_state.chain_released:
			chain_released = true

		update_chain_visual()

func _apply_movement_constraints() -> void:
	if has_chain:
		clamp_to_chain_limits()

func _post_physics_update() -> void:
	if has_chain:
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
