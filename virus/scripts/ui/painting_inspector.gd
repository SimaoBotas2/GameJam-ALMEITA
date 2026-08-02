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

	# Wait a frame so the same key press that closed the inspector
	# doesn't also register as a fresh "interact" on the painting.
	await get_tree().process_frame

	if target_player != null and target_player.has_method("unlock_interaction"):
		target_player.unlock_interaction()

	closed.emit()
	queue_free()
