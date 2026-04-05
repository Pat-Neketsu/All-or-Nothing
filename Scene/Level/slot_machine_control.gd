extends Control

@onready var slot1 = %Slot1
@onready var slot2 = %Slot2
@onready var slot3 = %Slot3

@onready var spin_button = %spin
@onready var result = %result
@onready var bet_input = %betInput

var symbols = [
	preload("res://Art/slot/bar.png"),
	preload("res://Art/slot/diamond.png"),
	preload("res://Art/slot/seven.png"),
	preload("res://Art/slot/watermelon.png"),
	preload("res://Art/slot/bell.png"),
	preload("res://Art/slot/cherry.png"),
	preload("res://Art/slot/horseshoe.png"),
	preload("res://Art/slot/lemon.png"),
	preload("res://Art/slot/heart.png"),
]

var current_bet : int = 0

func _ready():
	randomize()

func _on_spin_pressed():
	if bet_input.text.is_empty():
		result.text = "Enter Bet To Start!!"
		return
	
	current_bet = int(bet_input.text)
	
	if current_bet <= 0:
		result.text = "Invalid Bet!"
		return
	
	if current_bet > GameManager.point:
		result.text = "Not Enough Points"
		return
	
	bet_input.editable = false
	spin_button.disabled = true
	result.text = "Spinning....."
	
	await spin_animation()
	
	spin_button.disabled = false

func spin_animation():
	
	var r1 = randi_range(0,symbols.size() - 1) 
	var r2 = randi_range(0,symbols.size() - 1) 
	var r3 = randi_range(0,symbols.size() - 1)
	
	var interval = 0.05
	
	for i in range(20):
		slot1.texture = symbols[randi_range(0, symbols.size() - 1)]
		slot2.texture = symbols[randi_range(0, symbols.size() - 1)]
		slot3.texture = symbols[randi_range(0, symbols.size() - 1)]
		
		slot1.rotation_degrees = randf_range(-5,5)
		slot2.rotation_degrees = randf_range(-5,5)
		slot3.rotation_degrees = randf_range(-5,5)
		
		await get_tree().create_timer(interval).timeout
		
		slot1.rotation_degrees = 0
		slot2.rotation_degrees = 0
		slot3.rotation_degrees = 0
		
		interval += 0.01
	
	slot1.texture = symbols[r1]
	bounce_slot(slot1)
	
	await get_tree().create_timer(0.5).timeout 
	
	slot2.texture = symbols[r2]
	bounce_slot(slot2)
	
	await get_tree().create_timer(0.5).timeout 
	
	slot3.texture = symbols[r3]
	bounce_slot(slot3)
	
	await get_tree().create_timer(0.5).timeout 
	
	check_win(r1,r2,r3)

func bounce_slot(slot):

	slot.scale = Vector2(1,1)

	var tween = create_tween()

	tween.tween_property(
		slot,
		"scale",
		Vector2(1.2,1.2),
		0.15
	)

	tween.tween_property(
		slot,
		"scale",
		Vector2(1,1),
		0.15
	)

func check_win(r1,r2,r3):
	
	slot1.texture = symbols[r1]
	slot2.texture = symbols[r2]
	slot3.texture = symbols[r3]
	#777
	if r1 == 2 and r2 == 2 and r3 == 2:
		result.text = "JACKPOT!!!"
		GameManager.add_points(current_bet*10)
		flash_slots()
		bet_input.editable = true
		return
	#Diamond
	if r1 == 1 and r2 == 1 and r3 == 1:
		result.text = "BIG WIN!!"
		GameManager.add_points(current_bet*7)
		flash_slots()
		bet_input.editable = true
		return
	#BAR
	if r1 == 0 and r2 == 0 and r3 == 0:
		result.text = "Nice Win!!!"
		GameManager.add_points(current_bet*4)
		flash_slots()
		bet_input.editable = true
		return
	#HORSESHOE
	if r1 == 6 and r2 == 6 and r3 == 6:
		result.text = "Nice Win!!!"
		GameManager.add_points(current_bet*4)
		flash_slots()
		bet_input.editable = true
		return
	#Any #
	if r1 == r2 and r2 == r3:
		result.text = "Win!!!"
		GameManager.add_points(current_bet*2)
		flash_slots()
		bet_input.editable = true
		return
	#Cherry Win
	if (r1 == 5 and r2 == 5) or (r1 == 5 and r3 == 5) or (r2 == 5 and r3 == 5) :
		result.text = "Small Win!!!"
		GameManager.add_points(current_bet*2)
		flash_slots()
		bet_input.editable = true
		return
	#Lose
	result.text = "You Lose Try Again!!"
	GameManager.remove_points(current_bet)
	bet_input.editable = true

func flash_slots():
	
	for i in range(10):
		
		slot1.modulate = Color(1,1,0)
		slot2.modulate = Color(1,1,0)
		slot3.modulate = Color(1,1,0)
		
		await get_tree().create_timer(0.15).timeout
		
		slot1.modulate = Color(1,1,1)
		slot2.modulate = Color(1,1,1)
		slot3.modulate = Color(1,1,1)
		
		await get_tree().create_timer(0.15).timeout

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/casino.tscn")
