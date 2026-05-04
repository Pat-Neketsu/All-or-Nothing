extends Node2D

var bet_type
var value

@onready var label = %Label

func set_value(amount: int):
	label.text = str(amount)
