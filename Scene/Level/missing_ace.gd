extends Node2D

@onready var card_area = %CardArea
@onready var bet_input = %BetInput
@onready var result_label = %ResultLabel
@onready var multiplier_label = %MultiplierLabel
@onready var start_button = %StartButton
@onready var cash_out_button = %CashoutButton

var card_scene = preload("res://Scene/UI/card_2.tscn")

var ace_pool = [
	"res://Art/cards/ca.jpg",
	"res://Art/cards/sa.jpg",
	"res://Art/cards/ha.jpg",
	"res://Art/cards/da.jpg"
]

var card_pool = [
	"res://Art/cards/c2.jpg",
	"res://Art/cards/c3.jpg",
	"res://Art/cards/c4.jpg",
	"res://Art/cards/c5.jpg",
	"res://Art/cards/c6.jpg",
	"res://Art/cards/c7.jpg",
	"res://Art/cards/c8.jpg",
	"res://Art/cards/c9.jpg",
	"res://Art/cards/c10.jpg",
	"res://Art/cards/cj.jpg",
	"res://Art/cards/ck.jpg",
	"res://Art/cards/cq.jpg",
	"res://Art/cards/d2.jpg",
	"res://Art/cards/d3.jpg",
	"res://Art/cards/d4.jpg",
	"res://Art/cards/d5.jpg",
	"res://Art/cards/d6.jpg",
	"res://Art/cards/d7.jpg",
	"res://Art/cards/d8.jpg",
	"res://Art/cards/d9.jpg",
	"res://Art/cards/d10.jpg",
	"res://Art/cards/dk.jpg",
	"res://Art/cards/dq.jpg",
	"res://Art/cards/dj.jpg",
	"res://Art/cards/h2.jpg",
	"res://Art/cards/h3.jpg",
	"res://Art/cards/h4.jpg",
	"res://Art/cards/h5.jpg",
	"res://Art/cards/h6.jpg",
	"res://Art/cards/h7.jpg",
	"res://Art/cards/h8.jpg",
	"res://Art/cards/h9.jpg",
	"res://Art/cards/h10.jpg",
	"res://Art/cards/hk.jpg",
	"res://Art/cards/hq.jpg",
	"res://Art/cards/hj.jpg",
	"res://Art/cards/s2.jpg",
	"res://Art/cards/s3.jpg",
	"res://Art/cards/s4.jpg",
	"res://Art/cards/s5.jpg",
	"res://Art/cards/s6.jpg",
	"res://Art/cards/s7.jpg",
	"res://Art/cards/s8.jpg",
	"res://Art/cards/s9.jpg",
	"res://Art/cards/s10.jpg",
	"res://Art/cards/sk.jpg",
	"res://Art/cards/sq.jpg",
	"res://Art/cards/sj.jpg"
]

var cards = []

var playing = false

var input_locked = true

#card position
var start_x = 140
var spacing = 225
var y_pos = 480
var board_center_x = 350

var bet_amount = 0
var current_multiplier = 1.0
var current_win = 0

var card_count = 2

var round_locked = false

func start_game():
	
	if playing:
		return
	
	bet_amount = int(bet_input.text)
	
	if bet_amount <= 0:
		result_label.text = "Invalid bet"
		return
	
	if bet_amount > GameManager.point:
		result_label.text = "Not enough points"
		return
	
	GameManager.remove_points(bet_amount)
	
	current_multiplier = 1.0
	current_win = bet_amount * current_multiplier
	
	bet_input.editable = false
	start_button.disabled = true
	cash_out_button.disabled = false
	
	playing = true
	
	card_count = 2
	
	start_round()
	
	update_ui()

func start_round():
	clear_cards()
	cards.clear()
	input_locked = true
	
	spawn_cards()
	
	await show_shuffle_animation()
	
	await deal_animation()
	
	result_label.text = "Next pick risks " + str(current_win)
	
	assign_cards()
	
	input_locked = false

func show_shuffle_animation():
	
	if cards.size() < 2:
		return
	
	result_label.text = "Shuffling..."
	
	var base_positions = []
	
	for c in cards:
		base_positions.append(c.global_position)
	
	for i in range(12):
		# jitter
		for j in range(cards.size()):
			cards[j].global_position = base_positions[j] + Vector2(
				randf_range(-15, 15),
				randf_range(-15, 15)
			)
		
		# occasional swap
		if i % 3 == 0:
			var a = randi_range(0, cards.size() - 1)
			var b = randi_range(0, cards.size() - 1)
		
			var temp = cards[a].global_position
			cards[a].global_position = cards[b].global_position
			cards[b].global_position = temp
		
		await get_tree().create_timer(0.03).timeout
	
	# snap back clean
	for i in range(cards.size()):
		cards[i].global_position = base_positions[i]
	
	await get_tree().create_timer(0.2).timeout

func spawn_cards():
	for i in range(card_count):
		var card = card_scene.instantiate()
		card_area.add_child(card)
		
		var total_width = (card_count - 1) * spacing
		@warning_ignore("integer_division")
		var start_x_centered = board_center_x - total_width / 2
		
		card.global_position = Vector2(start_x_centered + i * spacing, y_pos + 200)
		card.scale = Vector2(1.0, 1.0)
		
		card.selected.connect(_on_card_selected)
		cards.append(card)

func deal_animation():
	
	for i in range(cards.size()):
		var c = cards[i]
		
		var total_width = (card_count - 1) * spacing
		@warning_ignore("integer_division")
		var start_x_centered = board_center_x - total_width / 2
		
		var tween = create_tween()
		tween.tween_property(
			c,
			"global_position",
			Vector2(start_x_centered  + i * spacing, y_pos),
			0.15
		).set_delay(i * 0.05)
		
		tween.tween_property(c, "scale", Vector2(1.3, 1.3), 0.25)
	
	await get_tree().create_timer(0.3).timeout

func _on_card_selected(card):
	
	if not playing:
		return
	
	if input_locked:
		return
	
	card.reveal()
	
	if card.is_ace:
		handle_win()
	else:
		handle_loss()

func handle_win():
	
	if current_multiplier < 4:
		result_label.text = "Lucky pick!"
	elif current_multiplier < 8:
		result_label.text = "You're getting hot!"
	elif current_multiplier < 16:
		result_label.text = "Risky..."
	else:
		result_label.text = "INSANE STREAK!"
	
	current_multiplier *= 2.0
	
	current_win = bet_amount * current_multiplier
	
	if current_multiplier >= 8.0:
		card_count = 3
	
	await get_tree().create_timer(1.2).timeout
	
	update_ui()
	
	start_round()

func handle_loss():
	
	result_label.text = "Wrong card!"
	
	playing = false
	
	reveal_all_cards()
	
	bet_input.editable = true
	start_button.disabled = false
	cash_out_button.disabled = true

func cash_out():
	
	if not playing:
		return
	
	GameManager.add_points(current_win)
	
	result_label.text = "Won: " + str(current_win)
	
	playing = false
	
	bet_input.editable = true
	start_button.disabled = false
	cash_out_button.disabled = true

func reveal_all_cards():
	
	for card in cards:
		card.reveal()

func clear_cards():
	
	for child in card_area.get_children():
		child.queue_free()

func update_ui():
	
	if current_multiplier <= 1.0:
		multiplier_label.text = "Multiplier: --"
	else:
		multiplier_label.text = "Multiplier: " + str(current_multiplier) + "x"

func assign_cards():
	var ace_index = randi_range(0, cards.size() - 1)
	var pool = card_pool.duplicate()
	pool.shuffle()
	
	var random_ace_texture = load(ace_pool.pick_random())
	
	for i in range(cards.size()):
		
		var c = cards[i]
		
		c.revealed = false
		
		if i == ace_index:
			c.is_ace = true
		else:
			c.is_ace = false
		
		if pool.is_empty():
			pool = card_pool.duplicate()
			pool.shuffle()
		
		if c.is_ace:
			c.ace_texture = random_ace_texture
		else:
			c.face_texture = load(pool.pop_back())



func _on_start_button_pressed() -> void:
	start_game()


func _on_cashout_button_pressed() -> void:
	cash_out()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/casino.tscn")
