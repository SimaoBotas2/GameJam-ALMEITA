extends CanvasLayer

signal closed

var target_player: Node = null

@onready var texture_rect: TextureRect = $Background/TextureRect
@onready var title_label: Label = $Background/TitleLabel

func open(closeup_texture: Texture2D, painting_title: String, player: Node) -> void:
	target_player = player
	texture_rect.texture = closeup_texture
	title_label.text = painting_title

	if target_player != null:
		if target_player.has_method("lock_movement"):
			target_player.lock_movement()
		if target_player.has_method("lock_interaction"):
			target_player.lock_interaction()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func close() -> void:
	if target_player != null and target_player.has_method("unlock_movement"):
		target_player.unlock_movement()

	# Esperamos um frame para o mesmo clique que fechou isto não contar logo
	# como um novo "interact" no quadro (senão abria e fechava no mesmo instante).
	await get_tree().process_frame

	if target_player != null and target_player.has_method("unlock_interaction"):
		target_player.unlock_interaction()

	closed.emit()
	queue_free()
