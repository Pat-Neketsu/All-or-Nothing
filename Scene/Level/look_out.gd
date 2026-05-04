extends Node2D

@onready var plane = %Plane
@onready var building = %Buildings
@onready var multiplier_label = %Multiplier
@onready var result_label = %ResultLabel
@onready var building_scene = preload("res://Scene/UI/building.tscn")
@onready var bet_input = %BetInput
@onready var ui = %UI
@onready var start_button = %StartButton

var base_gap := 180.0
var gap_size := 180.0

var base_speed := 200.0
var scroll_speed := 200.0

var base_spawn_delay := 1.5
var spawn_delay := 1.5

var min_gap := 80.0
var max_speed := 450.0

var shake_strength = 1.0
var shake_decay = 5.0
var original_position = Vector2.ZERO

var min_y = 200
var max_y = 450

var spawn_timer = 0.0

var bet_amount = 0
var playing = false

var building_cleared = 0
var current_multiplier = 0.1

const MAX_MULTIPLIER = 30.0

func _ready() -> void:
	original_position = position

func shake(amount: float):
	shake_strength = amount

func start_game():
	
	if playing:
		return
	
	if not plane.died.is_connected(game_over):
		plane.died.connect(game_over)
	
	bet_amount = int(bet_input.text)
	
	if bet_amount <= 0:
		result_label.text = "Invalid bet"
		return
	
	if bet_amount > GameManager.point:
		result_label.text = "Not enough points"
		return
	
	GameManager.remove_points(bet_amount)
	
	start_button.disabled = true
	
	playing = true
	building_cleared = 0
	current_multiplier = 0.1
	spawn_timer = 0
	
	ui.visible = false
	multiplier_label.visible = true
	
	plane.global_position = Vector2(165, 350)
	plane.velocity = Vector2.ZERO
	
	await get_tree().create_timer(0.4).timeout
	
	plane.game_running = true
	
	update_ui()

func on_pipe_passed():
	if not playing:
		return
	
	building_cleared += 1
	
	current_multiplier = min( 0.1 * (building_cleared + 1), MAX_MULTIPLIER)
	
	update_difficulty()
	update_ui()

func game_over():
	
	if not playing:
		return
	
	playing = false
	
	shake(15)
	await get_tree().create_timer(2.0).timeout
	
	for pipe in building.get_children():
		pipe.queue_free()
	
	var payout = bet_amount * current_multiplier
	GameManager.add_points(payout)
	
	result_label.text = "CRASHED! " + str(building_cleared) + " buildings"
	
	ui.visible = true
	start_button.disabled = false
	start_button.disabled = false
	
	plane.game_running = false

func _process(delta):
	
	if shake_strength > 0:
		position = original_position + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	else:
		position = original_position
	
	if not playing:
		return
	
	spawn_timer += delta
	
	if spawn_timer > spawn_delay:
		spawn_pipe()
		spawn_timer = 0
	
	for pipe in building.get_children():
		pipe.position.x -= scroll_speed * delta

func spawn_pipe():
	var pipe = building_scene.instantiate()
	building.add_child(pipe)
	
	var screen_width = get_viewport_rect().size.x
	var spawn_x = screen_width + 60
	
	var jitter = randf_range(-40, 40)
	var center_y = randf_range(200, 400) + jitter
	
	pipe.position = Vector2(spawn_x, center_y)
	
	pipe.get_node("Top").position.y = -gap_size * 0.5
	pipe.get_node("Bottom").position.y = gap_size * 0.5
	
	if building_cleared > 20 and randi() % 4 == 0:
		pipe.position.y += randf_range(-60, 60)

func update_difficulty():
	var t = float(building_cleared)
	
	gap_size = max(min_gap, base_gap - t * 2.2)
	
	scroll_speed = min(max_speed, base_speed + t * 6.0)
	
	spawn_delay = max(0.7, base_spawn_delay - t * 0.03)
	
	if t < 10:
		gap_size = 180
		scroll_speed = 200
		spawn_delay = 1.5
		
	elif t < 25:
		gap_size = max(120, 180 - (t - 10) * 4)
		scroll_speed = 200 + (t - 10) * 8
		spawn_delay = max(0.9, 1.5 - (t - 10) * 0.05)
		
	else:
		gap_size = max(80, 120 - (t - 25) * 2)
		scroll_speed = min(500, 320 + (t - 25) * 10)
		spawn_delay = max(0.7, 0.9 - (t - 25) * 0.02)

func _on_pipe_hit(body):
	if body.is_in_group("player"):
		game_over()

func update_ui():
	
	multiplier_label.text = "Multiplier : " + str(snapped(current_multiplier, 0.01)) + "x"	


func _on_start_button_pressed() -> void:
	start_game()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/casino.tscn")
