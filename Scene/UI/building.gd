extends Node2D

@onready var score_zone = $ScoreZone
@onready var top_hitbox = $Top
@onready var bottom_hitbox = $Bottom

func _ready():
	score_zone.body_entered.connect(_on_score_zone_body_entered)
	top_hitbox.body_entered.connect(_on_hit)
	bottom_hitbox.body_entered.connect(_on_hit)

func _on_score_zone_body_entered(body):
	if body.is_in_group("player"):
		get_tree().current_scene.on_pipe_passed()

func _on_hit(body):
	if body.is_in_group("player"):
		get_tree().current_scene.game_over()
