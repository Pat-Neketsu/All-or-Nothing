extends Area2D

@onready var play_button = %QuickGambleButton
@onready var label = %QuickGambleLabel
@onready var coin = %Coin

var original_coin_position = Vector2.ZERO

var head_texture = preload("res://Art/Chips/head.png")
var tail_texture = preload("res://Art/Chips/tail.png")

var flipping = false

func _ready():
	play_button.visible = false
	label.visible = false
	coin.visible = false
	original_coin_position = coin.position
	play_button.pressed.connect(_on_button_pressed)

func _on_body_entered(body):
	if body.name == "Player":
		play_button.visible = true
		label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		play_button.visible = false
		label.visible = false

func _on_button_pressed():
	if flipping:
		return
	
	if GameManager.point < 20:
		label.text = "Not Enough Chips!"
		return
	
	GameManager.remove_points(20)
	
	flipping = true;
	
	coin.visible = true
	
	label.text = "Flipping..."
	
	await flip_animation()
	
	var is_heads = randf() < 0.5
	
	if is_heads:
		coin.texture = head_texture
		GameManager.add_points(40)
		label.text = "Heads! +40"
	
	else:
		coin.texture = tail_texture
		label.text = "TAILS! Lost!"
	
	await get_tree().create_timer(1.6).timeout
	
	coin.visible = false
	
	flipping = false

func flip_animation():
	
	var jump_height = 120
	
	var jump_tween = create_tween()
	
	jump_tween.tween_property(
		coin,
		"position:y",
		original_coin_position.y - jump_height,
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	for i in range(10):
		
		var tween = create_tween()
		
		tween.tween_property(coin, "scale:x", 0.05, 0.04)
		
		await tween.finished
		
		if coin.texture == head_texture:
			coin.texture = tail_texture
		else:
			coin.texture = head_texture
		
		var tween2 = create_tween()
		
		tween2.tween_property(coin, "scale:x", 0.5, 0.04)
		
		await tween2.finished
	
	var fall_tween = create_tween()
	
	fall_tween.tween_property(
		coin,
		"position:y",
		original_coin_position.y,
		0.25
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await fall_tween.finished
