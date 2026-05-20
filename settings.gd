extends Control

@onready var panel = %Panel
@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SFXSlider
@onready var mute = %Mute

var muted = false;

var volume_down = preload("res://Art/icon/volumedown.png")
var volume_up = preload("res://Art/icon/volumeup.png")

func _ready():
	modulate.a = 0
	visible = false
	music_slider.value = GameManager.music_volume
	sfx_slider.value = GameManager.sfx_volume

func open():
	visible = true
	get_tree().paused = true
	
	scale = Vector2(0.9, 0.9)
	
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.25)
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)
	
	modulate.a = 0
	
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate:a", 1.0, 0.25)

func close():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	
	get_tree().paused = false
	visible = false

func _on_back_button_pressed():
	close()


func _on_facebook_pressed() -> void:
	OS.shell_open("https://web.facebook.com/jhaymark.onia.1")

func _on_music_slider_value_changed(value):
	GameManager.music_volume = value
	GameManager.apply_audio_settings()

func _on_sfx_slider_value_changed(value):
	GameManager.sfx_volume = value
	GameManager.apply_audio_settings()

func _on_mute_pressed() -> void:
	muted = !muted
	
	music_slider.editable = !muted
	sfx_slider.editable = !muted
	
	if muted:
		mute.icon = volume_down
		
		GameManager.last_music_volume = GameManager.music_volume
		GameManager.last_sfx_volume = GameManager.sfx_volume
		
		GameManager.music_volume = 0
		GameManager.sfx_volume = 0
	else:
		mute.icon = volume_up
		
		GameManager.music_volume = GameManager.last_music_volume
		GameManager.sfx_volume = GameManager.last_sfx_volume
	
	GameManager.apply_audio_settings()
