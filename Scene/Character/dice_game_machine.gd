extends Area2D

@onready var play_button = $"../diceGameButton"

func _ready():
	play_button.visible = false

func _on_body_entered(body):
	print("Entered", body.name)
	if body.name == "Player":
		play_button.visible = true


func _on_body_exited(body):
	print("Exited", body.name)
	if body.name == "Player":
		play_button.visible = false


func _on_dice_game_button_pressed() -> void:
	var player = get_tree().current_scene.get_node("Player")
	if player:
		GameManager.last_player_position = player.position
	get_tree().change_scene_to_file("res://Scene/Level/DiceGame.tscn")
