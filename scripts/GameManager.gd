extends Node

var point: int = 1000 #starting points
var last_player_position: Vector2 = Vector2.ZERO

func add_points(amount: int):
	point += amount

func remove_points(amount: int):
	point -= amount
	if point < 0:
		point = 0
