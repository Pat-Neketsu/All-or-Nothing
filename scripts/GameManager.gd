extends Node

var point: int = 1000 #starting points
var last_player_position: Vector2 = Vector2.ZERO

var last_music_volume := 1.0
var last_sfx_volume := 1.0

var music_volume := 0.8
var sfx_volume := 0.8

func _ready():
	apply_audio_settings()

func add_points(amount: int):
	point += amount

func remove_points(amount: int):
	point -= amount
	if point < 0:
		point = 0

func apply_audio_settings():
	print("Music:", GameManager.music_volume)
	print("SFX:", GameManager.sfx_volume)
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))
