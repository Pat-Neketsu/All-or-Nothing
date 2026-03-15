extends CharacterBody2D

@export var speed = 10
@export var starting_direction: Vector2 = Vector2(0,1)

@onready var animation_tree = $AnimationTree

func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	var direction = $CanvasLayer/Joystick.get_joystick_dir()
	update_animation_parameters(direction)
	velocity = direction * speed
	move_and_slide()

func update_animation_parameters(move_input: Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/idle/blend_position", move_input)
		animation_tree.set("parameters/walk/blend_position", move_input)
