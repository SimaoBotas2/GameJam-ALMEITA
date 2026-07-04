extends "res://scripts/objects/interaction_object.gd"

@export var target_node: NodePath
@export var scale_multiplier: Vector2 = Vector2(1.15, 1.15)
@export var tween_duration: float = 0.18

func _on_interact() -> void:
	var node_to_scale := _get_target_node()
	if node_to_scale == null:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		node_to_scale,
		"scale",
		node_to_scale.scale * scale_multiplier,
		tween_duration
	)

func _get_target_node() -> Node2D:
	if not target_node.is_empty():
		var custom_target := get_node_or_null(target_node)
		if custom_target is Node2D:
			return custom_target

	var sprite := get_node_or_null("Sprite2D")
	if sprite is Node2D:
		return sprite

	if self is Node2D:
		return self

	return null
