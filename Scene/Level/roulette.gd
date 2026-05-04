extends Node2D

@onready var wheel = %Wheel
@onready var spin_button = %SpinButton
@onready var result_label = %ResultLabel
@onready var ball = %Ball
@onready var chip_layer = %ChipArea
@onready var bet_label = %BetLabel
@onready var chip10 = %chip10
@onready var chip50 = %chip50
@onready var chip100 = %chip100
@onready var chip500 = %chip500

var chip_scene = preload("res://Scene/UI/Chip.tscn")

var spinning = false
var ball_angle = 0.0

var bet_map = {}

var chip_values = [10,50,100,500]
var selected_chip := 10

enum BetType {
	STRAIGHT,
	RED,
	BLACK,
	EVEN,
	ODD,
	HIGH,
	LOW,
	DOZEN1,
	DOZEN2,
	DOZEN3
}

var bets = []
var current_bet = 0
var total_bet := 0

var roulette_numbers = [
	0,32,15,19,4,21,2,
	25,17,34,6,27,13,
	36,11,30,8,23,10,
	5,24,16,33,1,
	20,14,31,9,
	22,18,29,7,
	28,12,35,3,26
]

func is_red(n):
	var red = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]
	return n in red

func is_even(n):
	return n != 0 and n % 2 == 0

func is_odd(n):
	return n != 0 and n % 2 == 1

func is_low(n):
	return n >= 1 and n <= 18

func is_high(n):
	return n >= 19 and n <= 36

func is_black(n):
	return n != 0 and not is_red(n)

func resolve_group_bet(bet_type, result_number):
	match bet_type:
		BetType.RED:
			return is_red(result_number)
		
		BetType.BLACK:
			return is_black(result_number)
		
		BetType.EVEN:
			return is_even(result_number)
		
		BetType.ODD:
			return is_odd(result_number)
		
		BetType.LOW:
			return is_low(result_number)
		
		BetType.HIGH:
			return is_high(result_number)
		
		BetType.DOZEN1:
			return result_number >= 1 and result_number <= 12
		
		BetType.DOZEN2:
			return result_number >= 13 and result_number <= 24
		
		BetType.DOZEN3:
			return result_number >= 25 and result_number <= 36
	
	return false

func _ready():
	for zone in %BetZones.get_children():
		zone.bet_clicked.connect(_on_bet_clicked)
	update_chip_ui()

func _on_chip_10_pressed():
	if spinning:
		return
	selected_chip = 10
	update_chip_ui()
func _on_chip_50_pressed():
	if spinning:
		return
	selected_chip = 50
	update_chip_ui()
func _on_chip_100_pressed():
	if spinning:
		return
	selected_chip = 100
	update_chip_ui()
func _on_chip_500_pressed():
	if spinning:
		return
	selected_chip = 500
	update_chip_ui()

func update_chip_ui():
	
	chip10.modulate = Color.WHITE
	chip50.modulate = Color.WHITE
	chip100.modulate = Color.WHITE
	chip500.modulate = Color.WHITE
	chip10.scale = Vector2(1,1)
	chip50.scale = Vector2(1,1)
	chip100.scale = Vector2(1,1)
	chip500.scale = Vector2(1,1)
	
	match selected_chip:
		10:
			chip10.modulate = Color.YELLOW
			chip10.scale =Vector2(1.2,1.2)
		50:
			chip50.modulate = Color.YELLOW
			chip50.scale =Vector2(1.2,1.2)
		100:
			chip100.modulate = Color.YELLOW
			chip100.scale =Vector2(1.2,1.2)
		500:
			chip500.modulate = Color.YELLOW
			chip500.scale =Vector2(1.2,1.2)
	
	

func _on_bet_clicked(type, value):
	
	if spinning:
		return
		
	if GameManager.point < selected_chip:
		result_label.text = "Insufficient balance"
		return
	
	place_bet(type, value)
	spawn_chip(type, value)

func spawn_chip(type, value):
	
	var chip = chip_scene.instantiate()
	chip_layer.add_child(chip)
	
	var zone = find_zone(type, value)
	if zone == null:
		return
	
	chip.bet_type = type
	chip.value = value
	
	chip.set_value(selected_chip)
	
	# Create unique stack key
	var key = str(type) + "_" + str(value)
	
	var stack_index = 0
	
	if bet_map.has(key):
		stack_index = bet_map[key].size() - 1
	
	var offset = Vector2(0, -stack_index * 8)
	
	chip.global_position = zone.global_position + offset
	
	# Animation
	chip.scale = Vector2(0,0)
	
	var tween = create_tween()
	tween.tween_property(
		chip,
		"scale",
		Vector2(1,1),
		0.25
	).set_trans(Tween.TRANS_BACK)\
	.set_ease(Tween.EASE_OUT)


func find_zone(type, value):
	
	for zone in %BetZones.get_children():
		
		if zone.bet_type == type:
			
			if type == BetType.STRAIGHT:
				if zone.value == value:
					return zone
			else:
				return zone
	
	return null

func place_bet(type: BetType, value: int):
	var amount = selected_chip
	
	if GameManager.point < amount:
		result_label.text = "Not enough Points"
		return
	
	bets.append({
		"type": type,
		"value": value,
		"amount": amount
	})
	
	
	GameManager.remove_points(amount)
	
	total_bet += amount
	bet_label.text = "Total Bet: " + str(total_bet)
	
	var key = str(type) + "_" + str(value)
	
	if not bet_map.has(key):
		bet_map[key] = []
	
	bet_map[key].append(amount)

func clear_bets():
	bets.clear()
	bet_map.clear()
	total_bet = 0
	
	bet_label.text = "Total Bet: 0"
	
	for chip in chip_layer.get_children():
		var tween = create_tween()
		
		tween.tween_property(
			chip,
			"scale",
			Vector2(0,0),
			0.2
		)
		
		tween.tween_callback(chip.queue_free)

func calculate_payout(result_number: int):
	
	var winning_keys = []
	
	for bet in bets:
	
		var win = false
		var payout = 0
		
		match bet.type:
			
			BetType.STRAIGHT:
				if bet.value == result_number:
					win = true
					payout = bet.amount * 36
			
			_:
				if resolve_group_bet(bet.type, result_number):
					
					win = true
					
					match bet.type:
						BetType.RED, BetType.BLACK, BetType.EVEN, BetType.ODD, BetType.LOW, BetType.HIGH:
							
							payout = bet.amount * 2
						
						BetType.DOZEN1, BetType.DOZEN2, BetType.DOZEN3:
							
							payout = bet.amount * 3
							
		if win:
			
			GameManager.add_points(payout)
			
			# Save winning key
			var key = str(bet.type) + "_" + str(bet.value)
			winning_keys.append(key)
			
	# 🔥 After calculating — collect losers
	collect_losing_chips(winning_keys)

func collect_losing_chips(winning_keys):
	
	for chip in chip_layer.get_children():
		
		var key = str(chip.bet_type) + "_" + str(chip.value)
		
		# If not winning → collect it
		if key not in winning_keys:
			
			var tween = create_tween()
			
			# Move toward dealer area
			var dealer_pos = Vector2(
				get_viewport_rect().size.x + 200,
				get_viewport_rect().size.y + 200
			)
			
			tween.tween_property(
				chip,
				"global_position",
				dealer_pos,
				0.4
			)
			
			tween.tween_property(
				chip,
				"scale",
				Vector2(0,0),
				0.2
			)
			
			tween.tween_callback(chip.queue_free)

func _on_spin_button_pressed():
	if spinning:
		return
	
	if bets.is_empty():
		result_label.text = "Place a bet first!!"
		return
		
	spinning = true
	
	spin_button.disabled = true 
	
	result_label.text = "Spinning..."
	
	var winning_index = randi_range(0, roulette_numbers.size() - 1)
	
	await spin_to_index(winning_index)
	
	var number = roulette_numbers[winning_index]
	result_label.text = "Result: " + str(number)
	
	calculate_payout(number)
	
	await get_tree().create_timer(4.0).timeout
	
	reset_round()
	
	spinning = false
	spin_button.disabled = false

func reset_round():
	
	clear_bets()
	
	result_label.text = "Place your bets"

func spin_to_index(index):
	var slot_count = roulette_numbers.size()
	var slot_angle = 360.0 / slot_count
	
	var outer_radius = 350
	var inner_radius = 300
	
	var target_angle_deg = index * slot_angle
	
	target_angle_deg -= 11 * slot_angle
	
	var target_angle = deg_to_rad(target_angle_deg)
	
	var extra_spins = deg_to_rad(360 * randi_range(6, 8))
	
	var start_ball_angle = ball_angle
	var final_ball_angle = target_angle - extra_spins
	
	var start_wheel_rotation = wheel.rotation
	var wheel_extra_spins = deg_to_rad(360 * randi_range(6, 8))
	var final_wheel_rotation = start_wheel_rotation + wheel_extra_spins
	
	var duration = 5.5
	var time_passed = 0.0
	
	while time_passed < duration:
		var t = time_passed / duration
		
		var eased_t = 1.0 - pow(1.0 - t, 3)
		
		wheel.rotation = lerp(
			start_wheel_rotation,
			final_wheel_rotation,
			eased_t
		)
		
		ball_angle = lerp(
			start_ball_angle,
			final_ball_angle,
			eased_t
		)
		
		var radius
		
		if t < 0.7:
			radius = outer_radius
		else:
			var drop_t = (t - 0.7) / 0.3
			radius = lerp(outer_radius, inner_radius, drop_t)
		
		ball.position.x = cos(ball_angle) * radius
		ball.position.y = sin(ball_angle) * radius
		
		await get_tree().create_timer(0.01).timeout
		time_passed += 0.01
		
	snap_ball_exact(index, slot_angle, inner_radius)

func snap_ball_exact(index, slot_angle, radius):
	var corrected_index = (index - 11) % roulette_numbers.size()
	
	var angle_deg = corrected_index * slot_angle
	var angle_rad = deg_to_rad(angle_deg)
	
	ball_angle = angle_rad
	
	var target_pos = Vector2(
		cos(angle_rad) * radius,
		sin(angle_rad) * radius
	)
	
	animate_ball_bounce(target_pos)

func animate_ball_bounce(target_pos: Vector2):
	var tween = create_tween()
	
	var bounce_pos = target_pos * 1.02
	
	tween.tween_property(ball, "position", bounce_pos, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(ball, "position", target_pos, 0.12)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(ball, "position", target_pos, 0.1)

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/casino.tscn")
