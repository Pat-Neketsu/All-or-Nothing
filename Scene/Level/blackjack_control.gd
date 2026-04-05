extends Control

@onready var dealer_cards = %DealerCards
@onready var player_cards = %PlayerCards

@onready var dealer_score_label = %DealerScore
@onready var player_score_label = %PlayerScore
@onready var result_label = %ResultLabel

@onready var deal_button = %DealButton
@onready var hit_button = %HitButton
@onready var stand_button = %StandButton

@onready var bet_input = %betInput

var card_back_texture = preload("res://Art/cards/back.jpg")

var card_scene = preload("res://Scene/UI/Card.tscn")

var deck = []

var current_bet = 0

var dealer_hand = []
var player_hand = []

func create_deck():
	var suits = ["s", "h", "d", "c"]
	var values =["a", "2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k"]
	
	deck.clear()
	
	for suit in suits:
		for value in values:
			var card_name = suit + value
			deck.append(card_name)

func shuffle_deck():
	deck.shuffle()

func draw_card():
	if deck.is_empty():
		create_deck()
		shuffle_deck()
		
	return deck.pop_back()

func add_card_to_hand(card_name, container):
	var card = card_scene.instantiate()
	
	var texture_path = "res://Art/cards/"+ card_name +".jpg"
	card.texture = load(texture_path)
	container.add_child(card)
	
	card.position.y = -80
	
	var tween = create_tween()
	
	tween.tween_property(
		card,
		"position:y",
		0,
		0.8
	)
	await tween.finished

func clear_cards(container):
	for child in container.get_children():
		child.queue_free()

func _on_deal_button_pressed():
	
	if bet_input.text.is_empty():
		result_label.text = "Enter Bet To Start!!"
		return
	
	current_bet = int(bet_input.text)
	
	if current_bet <= 0:
		result_label.text = "Invalid Bet!"
		return
	
	if current_bet > GameManager.point:
		result_label.text = "Not Enough Points"
		return
	
	dealer_score_label.text = "Score: 0"
	player_score_label.text = "Score: 0"
	
	result_label.text = "Dealing.."
	
	result_label.modulate = Color(0,0,0)
	
	bet_input.editable = false
	deal_button.disabled = true
	clear_cards(player_cards)
	clear_cards(dealer_cards)
	
	player_hand.clear()
	dealer_hand.clear()
	
	create_deck()
	shuffle_deck()
	
	var p1 = draw_card()
	var p2 = draw_card()
	var d1 = draw_card()
	var d2 = draw_card()
	
	player_hand.append(p1)
	player_hand.append(p2)
	
	dealer_hand.append(d1)
	dealer_hand.append(d2)
	
	await get_tree().create_timer(0.3).timeout
	add_card_to_hand(p1, player_cards)
	
	await get_tree().create_timer(0.3).timeout
	add_card_to_hand(d1, dealer_cards)
	
	await get_tree().create_timer(0.3).timeout
	add_card_to_hand(p2, player_cards)
	
	await get_tree().create_timer(0.3).timeout
	add_card_back(dealer_cards)
	
	hit_button.disabled = false
	stand_button.disabled = false
	
	result_label.text = "Hit or Stand??"
	
	update_player_score()
	
	dealer_score_label.text = "Score: ?"
	
	if calculate_hand_value(player_hand) == 21 and player_hand.size() == 2:
		result_label.text = "BLACKJACK!!"
		GameManager.add_points(current_bet *2)
		animate_result()
		result_label.modulate = Color(1,1,0)
		
		end_round()

func update_player_score():
	var player_score = calculate_hand_value(player_hand)

	player_score_label.text = "Score: " + str(player_score)

func add_card_back(container):
	var card = card_scene.instantiate()

	card.texture = card_back_texture

	container.add_child(card)

func calculate_hand_value(hand):
	var total = 0
	var aces = 0
	
	for card in hand:
		var value = card.right(card.length() - 1)
		
		if value in ["j", "q", "k"]:
			total += 10
		elif value == "a":
			total += 11
			aces += 1
		else:
			total += int(value)
	
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	
	return total

func _on_hit_button_pressed():
	var card = draw_card()
	
	player_hand.append(card)
	
	await get_tree().create_timer(0.3).timeout
	add_card_to_hand(card, player_cards)
	
	update_player_score()
	
	if calculate_hand_value(player_hand) > 21:
		result_label.text = "Bust!!"
		GameManager.remove_points(current_bet)
		animate_result()
		
		end_round()
	

func _on_stand_button_pressed():
	
	result_label.text = "Dealer thinking..."
	
	await get_tree().create_timer(1.0).timeout
	
	reveal_dealer_card()
	
	await dealer_turn()
	
	check_winner()
	
	end_round()

func reveal_dealer_card():
	
	var hidden_card = dealer_cards.get_child(1)
	
	var tween = create_tween()
	
	# Flip closed
	tween.tween_property(
		hidden_card,
		"scale:x",
		0,
		0.5
	)
	
	tween.tween_callback(func():
		
		var real_card = dealer_hand[1]
		
		var texture_path = "res://Art/cards/" + real_card + ".jpg"
		
		hidden_card.texture = load(texture_path)
		
	)
	
	# Flip open
	tween.tween_property(
		hidden_card,
		"scale:x",
		1,
		0.15
	)
	
	await tween.finished
	update_scores()

func dealer_turn():

	while calculate_hand_value(dealer_hand) < 17:
		
		await get_tree().create_timer(1.0).timeout
		
		var card = draw_card()
		
		dealer_hand.append(card)
		
		add_card_to_hand(card, dealer_cards)
		
		update_scores()

func update_scores():
	var player_score = calculate_hand_value(player_hand)
	var dealer_score = calculate_hand_value(dealer_hand)
	
	player_score_label.text = "Score: " + str(player_score)
	dealer_score_label.text = "Score: " + str(dealer_score)

func check_winner():
	var player_score = calculate_hand_value(player_hand)
	var dealer_score = calculate_hand_value(dealer_hand) 
	
	if dealer_score > 21:
		result_label.text = "Dealer Bust! You WIN!!"
		result_label.modulate = Color(1,1,0)
		animate_result()
		await get_tree().create_timer(1.5).timeout
		result_label.modulate = Color(0,0,0)
		GameManager.add_points(current_bet)
	elif player_score > dealer_score:
		result_label.text = "You WIN!!"
		animate_result()
		result_label.modulate = Color(1,1,0)
		await get_tree().create_timer(1.5).timeout
		result_label.modulate = Color(0,0,0)
		GameManager.add_points(current_bet)
	elif player_score < dealer_score:
		result_label.text = "Dealer WINS"
		animate_result()
		GameManager.remove_points(current_bet)
	else:
		result_label.text = "Push (DRAW)"
		animate_result()

func animate_result():

	result_label.scale = Vector2(1,1)

	var tween = create_tween()

	tween.tween_property(
		result_label,
		"scale",
		Vector2(1.3,1.3),
		0.5
	)

	tween.tween_property(
		result_label,
		"scale",
		Vector2(1,1),
		0.5
	)

func end_round():
	bet_input.editable = true
	deal_button.disabled = false
	hit_button.disabled = true
	stand_button.disabled = true

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/casino.tscn")
