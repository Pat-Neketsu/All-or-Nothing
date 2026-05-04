extends CharacterBody2D

var gravity = 400
var jump_force = -250

var game_running = false

signal died

func _physics_process(delta):
	
	if not game_running:
		return
	
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("click"):
		velocity.y = jump_force
	
	move_and_slide()
	
	update_rotation()
	
	if global_position.y < -10:
		global_position.y = -10
		velocity.y = 0
	
	if global_position.y > 700:
		emit_signal("died")

func update_rotation():
	
	var target_rotation = velocity.y * 0.001
	
	target_rotation = clamp(target_rotation, -0.5, 1.0)
	
	rotation = lerp(rotation, target_rotation, 0.13)

func _ready():
	add_to_group("player")
