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

	# Esperamos a tecla ser mesmo largada antes de destrancar a interação.
	# Só esperar um frame não chega sempre — is_action_just_pressed() é lido
	# no _physics_process(), que corre a um ritmo diferente do process_frame,
	# e às vezes ainda via a tecla como "acabada de premir" e reabria o quadro.
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	if target_player != null and target_player.has_method("unlock_interaction"):
		target_player.unlock_interaction()

	closed.emit()
	queue_free()
