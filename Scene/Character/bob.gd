extends CharacterBody2D

@export var move_speed : float = 300
@export var starting_direction : Vector2 = Vector2(0, 0.5)

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	if GameManager.last_player_position != Vector2.ZERO:
		call_deferred("_set_player_position")
	else:
		update_animation_parameter(starting_direction)

func _set_player_position():
	if GameManager.last_player_position != Vector2.ZERO:
		self.position = GameManager.last_player_position

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	update_animation_parameter(input_direction)
	
	velocity = input_direction * move_speed
	
	move_and_slide()
	
	pick_new_state()

func update_animation_parameter(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/idle/blend_position", move_input)
		animation_tree.set("parameters/walk/blend_position", move_input)

func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
