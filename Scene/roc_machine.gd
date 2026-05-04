extends Area2D

@onready var play_button = %ROCButton

func _ready():
	play_button.visible = false
	play_button.pressed.connect(_on_button_pressed)

func _on_body_entered(body):
	if body.name == "Player":
		play_button.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		play_button.visible = false

func _on_button_pressed():
	GameManager.last_player_position = get_parent().get_node("../Player").position
	get_tree().change_scene_to_file("res://Scene/Level/roc.tscn")
