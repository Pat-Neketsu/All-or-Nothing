extends Control

@onready var bet_input = %betInput
@onready var result_label = %result
@onready var roll_button = %roll
@onready var dice_texture = %dice

var dice_images = [
	preload("res://Art/dice/dice1.png"),
	preload("res://Art/dice/dice2.png"),
	preload("res://Art/dice/dice3.png"),
	preload("res://Art/dice/dice4.png"),
	preload("res://Art/dice/dice5.png"),
	preload("res://Art/dice/dice6.png"),
]

var current_bet: int = 0

func _ready():
	roll_button.disabled = true

func _on_play_pressed() -> void:
	if bet_input.text.is_empty():
		result_label.text = "Enter a bet amount"
		return
	current_bet = int(bet_input.text)
	
	if current_bet <= 0:
		result_label.text = "Bet must be greater than 0!"
		return
	
	if current_bet > GameManager.point:
		result_label.text = "Not enough points!"
		return
	
	result_label.text = "Bet Accepted! Click to Roll Dice"
	roll_button.disabled = false
	
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/casino.tscn")

func _on_roll_pressed() -> void:
	roll_button.disabled = true
	bet_input.editable = false
	result_label.text = "Rolling..."
	await randomize_dice_animation(1.5)
	determine_winner()
	bet_input.editable = true

func randomize_dice_animation(duration : float) -> void:
	
	var time_passed = 0.0
	var interval = 0.1
	var dice_position = dice_texture.position
	
	while time_passed < duration:
	
		var roll = randi_range(1,6)
		dice_texture.texture = dice_images[roll - 1]
		
		dice_texture.position.x += randf_range(-10,10)
		dice_texture.position.y += randf_range(-10,10)
		dice_texture.position = dice_position
		dice_texture.rotation = randf_range(-25, 25)
		
		await get_tree().create_timer(interval).timeout  
		time_passed += interval
	
	dice_texture.rotation_degrees = 0
	dice_texture.position = dice_position

func determine_winner():
	var player_roll = randi_range(1,6)
	
	dice_texture.texture = dice_images[player_roll - 1]
	bounce_dice()
	
	if player_roll > 4:
		result_label.text = "You Win!!!"
		GameManager.add_points(current_bet)
		flash_dice()
	else:
		result_label.text = "You Lose. Try Again....."
		GameManager.remove_points(current_bet)

func flash_dice():

	for i in range(5):

		dice_texture.modulate = Color(1,1,0)

		await get_tree().create_timer(0.15).timeout

		dice_texture.modulate = Color(1,1,1)

		await get_tree().create_timer(0.15).timeout

func bounce_dice():

	dice_texture.scale = Vector2(1,1)

	var tween = create_tween()

	tween.tween_property(
		dice_texture,
		"scale",
		Vector2(1.3,1.3),
		0.15
	)

	tween.tween_property(
		dice_texture,
		"scale",
		Vector2(1,1),
		0.15
	)
