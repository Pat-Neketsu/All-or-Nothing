extends Node2D

@onready var settings_scene = preload("res://Scene/UI/settings.tscn")
var settings_instance

func _ready():
	settings_instance = settings_scene.instantiate()
	%UI.add_child(settings_instance)
	settings_instance.visible = false

func _on_settings_pressed() -> void:
	settings_instance.open()
