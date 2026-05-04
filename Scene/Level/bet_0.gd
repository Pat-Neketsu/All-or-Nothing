extends Area2D

signal bet_clicked(type, value)

@export var bet_type: int
@export var value: int = -1

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		bet_clicked.emit(bet_type, value)
