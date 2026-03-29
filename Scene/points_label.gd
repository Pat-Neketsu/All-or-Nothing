extends Label

func _process(_delta):
	text = "Points: " + str(GameManager.point)
