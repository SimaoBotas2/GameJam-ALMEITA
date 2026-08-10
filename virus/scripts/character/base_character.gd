class_name BaseCharacter
extends CharacterBody2D

# --- Movimento ---
@export var move_speed: float = 350
@export var starting_direction: Vector2 = Vector2.ZERO
@export var scene_limit_margin: Vector2 = Vector2(8, 12)

# --- Interação ---
var current_interaction_object: Node = null
var interaction_locked: bool = false
var movement_locked: bool = false
var inventory: Dictionary = {}

# --- Skins / animação ---
# current_skin diz qual está ativa agora. skin_animation_trees mapeia o nome
# de cada skin (ex: "default", "after_glass") para o caminho do AnimationTree
# dela — cada skin tem o seu próprio par AnimationPlayer + AnimationTree,
# todos a mexer no mesmo Sprite2D, e só um está ativo de cada vez.
@export var current_skin: String = "default"
@export var skin_animation_trees: Dictionary = {}

var animation_tree: AnimationTree
var state_machine

# --- Referências a nós ---
@onready var camera: Camera2D = $Camera2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D
@onready var footsteps_player: AudioStreamPlayer = $FootstepsPlayer

# --- Ciclo de vida ---
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	add_to_group("player")

	# Se já mudámos de skin nalguma sala anterior, o GameState lembra-se —
	# senão perdia-se sempre que se muda de sala (cada sala cria uma
	# personagem nova, com o current_skin da própria scene).
	var game_state = get_node_or_null("/root/GameState")
	if game_state != null and game_state.current_skin != "default":
		current_skin = game_state.current_skin

	sync_inventory_from_state()
	_activate_skin(current_skin)

	if footsteps_player != null and footsteps_player.stream is AudioStreamWAV:
		var footsteps_stream := footsteps_player.stream as AudioStreamWAV
		footsteps_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	update_animation_parameters(starting_direction)

func _physics_process(_delta: float) -> void:
	var input_direction = Vector2.ZERO
	if not movement_locked:
		input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		).normalized()

	velocity = input_direction * move_speed
	move_and_slide()
	_apply_movement_constraints()
	clamp_to_scene_limits()
	_post_physics_update()

	update_animation_parameters(input_direction)
	pick_new_state()
	update_footsteps_audio()
	handle_interaction()

# --- Movimento ---

# Dá para sobrepor isto nas subclasses para meter restrições de movimento extra
# (ex: a corrente). Corre depois do move_and_slide() e antes do clamp_to_scene_limits().
func _apply_movement_constraints() -> void:
	pass

# Dá para sobrepor isto nas subclasses para atualizar coisas todos os frames
# (ex: o visual da corrente). Corre depois do clamp_to_scene_limits() e antes das animações.
func _post_physics_update() -> void:
	pass

# Não deixa a personagem sair da área visível da câmara.
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

# --- Animação ---

# Manda a direção do movimento para a AnimationTree ativa (para o blend do
# Walk) e vira o sprite (flip_h) consoante ando para a esquerda ou direita.
func update_animation_parameters(move_input: Vector2) -> void:
	if move_input != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", move_input)

	if move_input.x < 0:
		sprite.flip_h = true
	elif move_input.x > 0:
		sprite.flip_h = false

# Corre todos os frames e decide se a state machine devia estar em Walk ou
# Idle, consoante a personagem tem velocidade ou não.
func pick_new_state() -> void:
	if velocity != Vector2.ZERO:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

# --- Skins ---

# Desliga a AnimationTree de todas as skins menos a pedida, e atualiza
# animation_tree/state_machine para apontarem para a que ficou ativa.
# É "privada" (underscore) porque não trata de repor a pose (Walk/Idle) da
# skin nova — quem quiser trocar de skin a sério devia usar o set_skin().
func _activate_skin(skin_name: String) -> void:
	for skin in skin_animation_trees:
		var tree: AnimationTree = get_node_or_null(skin_animation_trees[skin])
		if tree != null:
			tree.active = (skin == skin_name)

	var new_tree: AnimationTree = get_node_or_null(skin_animation_trees.get(skin_name))
	if new_tree != null:
		animation_tree = new_tree
		state_machine = animation_tree.get("parameters/playback")

	current_skin = skin_name

# Ponto de entrada público para trocar de skin em runtime (ex: a personagem
# perder o braço a meio da história). Ativa a skin nova e já repõe logo o
# estado de animação certo (Walk/Idle), para não ficar um frame na pose errada.
func set_skin(skin_name: String) -> void:
	if not skin_animation_trees.has(skin_name):
		push_warning("Skin '%s' not found in skin_animation_trees." % skin_name)
		return

	_activate_skin(skin_name)
	pick_new_state()

	var game_state = get_node_or_null("/root/GameState")
	if game_state != null:
		game_state.current_skin = skin_name

# --- Inventário ---

func sync_inventory_from_state() -> void:
	var game_state = get_node_or_null("/root/GameState")
	if game_state != null:
		inventory = game_state.inventory.duplicate(true)

func add_to_inventory(item_name: String, amount: int = 1) -> void:
	if amount <= 0:
		return

	var game_state = get_node_or_null("/root/GameState")
	if game_state == null:
		push_warning("GameState not found; inventory could not be updated.")
		return

	game_state.add_item(item_name, amount)
	sync_inventory_from_state()

func remove_from_inventory(item_name: String, amount: int = 1) -> bool:
	var game_state = get_node_or_null("/root/GameState")
	if game_state == null:
		push_warning("GameState not found; inventory could not be updated.")
		return false

	var removed: bool = game_state.remove_item(item_name, amount)
	if removed:
		sync_inventory_from_state()
	return removed

func get_inventory_count(item_name: String) -> int:
	return inventory.get(item_name, 0)

# --- Som ---

func update_footsteps_audio() -> void:
	if footsteps_player == null:
		return

	if velocity.length() > 0.0:
		if not footsteps_player.playing:
			footsteps_player.play()
	else:
		footsteps_player.stop()

# --- Interação ---

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

func lock_movement() -> void:
	movement_locked = true

func unlock_movement() -> void:
	movement_locked = false

# Os objetos interativos são StaticBody2D com uma Area2D filha (InteractionZone)
# só para deteção — é essa área que gera o sinal, mas quem tem o script (e os
# métodos show_prompt/interact) é o pai dela, por isso subimos com get_parent().
func _on_interaction_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("interaction_object"):
		var target = area.get_parent()
		current_interaction_object = target
		if not interaction_locked and target.has_method("show_prompt"):
			target.show_prompt()

func _on_interaction_detector_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_interaction_object:
		if current_interaction_object.has_method("hide_prompt"):
			current_interaction_object.hide_prompt()
		current_interaction_object = null
