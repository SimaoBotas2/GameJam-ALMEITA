extends CharacterBody2D

@export var move_speed : float = 350
@export var starting_direction: Vector2 = Vector2.ZERO #probably gonna change

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

#not necessary as long as the idle animation is just one
func _ready():
	animation_tree.active = true
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	#Get input diretion
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_direction * move_speed
	move_and_slide()
	
	update_animation_parameters(input_direction)
	pick_new_state()

#animation in function of move_input
func update_animation_parameters(move_input: Vector2):
	if move_input != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", move_input)
		#animation_tree.set("parameters/Idle/blend_position", move_input) 
		#not necessary as long as the idle animation is just one

#animation in function of the velocity
func pick_new_state():
	if velocity != Vector2.ZERO:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
