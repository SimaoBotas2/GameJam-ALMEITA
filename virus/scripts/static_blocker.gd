extends StaticBody2D

@export var shape_size: Vector2 = Vector2(100, 100)
@export var shape_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	var cs := $CollisionShape2D
	var rect := RectangleShape2D.new()
	rect.size = shape_size
	cs.shape = rect
	cs.position = shape_offset
