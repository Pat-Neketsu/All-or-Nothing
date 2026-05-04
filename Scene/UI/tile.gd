extends Area2D

signal clicked(tile)

var is_crash = false
var is_revealed = false

@onready var sprite = %icon

func _input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and  not is_revealed:
		emit_signal("clicked", self)

func reveal():
	is_revealed = true
	
	if is_crash:
		sprite.texture = preload("res://Art/RiseOrCrash/Crash.png")
	else:
		sprite.texture = preload("res://Art/RiseOrCrash/Rise.png")
		
		scale = Vector2(0,0)
		
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1,1), 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
