extends Node2D

@onready var grid = %Grid
@onready var multiplier_label = %MultiplierLabel
@onready var result_label = %ResultLabel
@onready var bet_inpuit = %BetInput
@onready var start_button = %StartButton
@onready var cash_out_button = %CashOutButton

var tile_scene = preload("res://Scene/UI/tile.tscn")

var grid_size = 5
var crash_count = 5

var tiles = []
var playing = false
var revealed_count = 0

var first_click = true

var bet_amount = 0 
var current_multiplier = 1.0

func create_grid():
	
	var spacing = 100
	tiles.clear()
	
	for x in range(grid_size):
		for y in range(grid_size):
			var tile = tile_scene.instantiate()
			grid.add_child(tile)
			
			tile.position = Vector2(x * spacing, y * spacing)
			
			tile.clicked.connect(_on_tile_clicked)
			
			tiles.append(tile)

func generate_crash():
	var available_tiles = tiles.duplicate()
	
	for i in range(crash_count):
		var index = randi_range(0, available_tiles.size() - 1)
		var tile = available_tiles[index]
		
		tile.is_crash = true
		
		available_tiles.remove_at(index)

func start_game():
	
	if playing:
		return
	
	first_click = true
	
	if not bet_inpuit.text.is_valid_int():
		result_label.text = "Invalid bet!"
		return
	
	bet_amount = int(bet_inpuit.text)
	
	if bet_amount <= 0:
		result_label.text = "Invalid bet!"
		return
	
	if bet_amount > GameManager.point:
		result_label.text = "Not enough points"
		return
	
	GameManager.remove_points(bet_amount)
	
	start_button.disabled = true
	bet_inpuit.editable = false
	
	result_label.text = "Click to Play"
	
	clear_board()
	
	create_grid()
	
	generate_crash()
	
	cash_out_button.disabled = false
	
	playing = true
	revealed_count = 0
	current_multiplier = 1.0
	
	update_ui()

func _on_tile_clicked(tile):

	if not playing:
		return
	
	if tile.is_revealed:
		return
	
	if first_click:
		if tile.is_crash:
			tile.is_crash = false
			assign_new_crash(tile)
		
		first_click = false
	
	tile.reveal()
	
	if tile.is_crash:
		handle_loss()
	else:
		handle_safe()

func handle_safe():
	revealed_count += 1
	
	current_multiplier = min(pow(1.2, revealed_count), 50)
	
	update_ui()

func handle_loss():
	
	result_label.text = "CRAASHH You Lost"
	
	
	disable_all_tiles()
	
	await get_tree().create_timer(0.4).timeout
	
	playing = false
	
	reveal_all_crash()
	
	start_button.disabled = false
	bet_inpuit.editable = true
	cash_out_button.disabled = true

func reveal_all_crash():
	
	for tile in tiles:
		if tile.is_crash:
			tile.reveal()

func cash_out():
	if not playing:
		return
	
	var win = bet_amount * current_multiplier
	
	GameManager.add_points(win)
	
	result_label.text = "Cashed out: " + str(win)
	
	disable_all_tiles()
	
	start_button.disabled = false
	bet_inpuit.editable = true
	cash_out_button.disabled = true
	
	playing = false

func clear_board():
	
	for tile in grid.get_children():
		tile.queue_free()
	
	tiles.clear()

func disable_all_tiles():
	for tile in tiles:
		tile.input_pickable = false

func assign_new_crash(exclude_tile):
	
	var valid_tiles = []
	
	for t in tiles:
		if t != exclude_tile and not t.is_crash and not t.is_revealed:
			valid_tiles.append(t)
	
	if valid_tiles.is_empty():
		return  # safety fallback
	
	var new_tile = valid_tiles.pick_random()
	
	new_tile.is_crash = true

func update_ui():
	
	var tween = create_tween()
	tween.tween_property(
		multiplier_label,
		"text",
		"Multiplier : " + str(snapped(current_multiplier, 0.01)) + "x",
		0.1
	)
	
	start_button.disabled = playing
	cash_out_button.disabled = not playing
	bet_inpuit.editable = not playing

func reset_round():
	first_click = true
	playing = false
	revealed_count = 0
	current_multiplier = 1.0
	bet_amount = 0

func _on_start_button_pressed() -> void:
	start_game()

func _on_cash_out_button_pressed() -> void:
	cash_out()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/casino.tscn")
