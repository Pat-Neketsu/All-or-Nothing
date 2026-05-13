extends Area2D

signal selected(card)

var is_ace = false
var revealed = false
var face_texture = null
var ace_texture = null

@onready var sprite = %Sprite2D

var back_texture = preload("res://Art/cards/back.jpg")

func _ready():
	sprite.texture = back_texture

func _input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and not revealed:
		emit_signal("selected", self)

func reveal():
	
	if revealed:
		return
	
	revealed = true
	
	var tween = create_tween()
	
	tween.tween_property(sprite, "scale:x", 0.3, 0.25)
	
	await tween.finished
	
	if is_ace:
		sprite.texture = ace_texture
	else:
		sprite.texture = face_texture
	
	var tween2 = create_tween()
	
	tween2.tween_property(sprite, "scale:x", 1.3, 0.25)
	
	tween2.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	tween2.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.15)
