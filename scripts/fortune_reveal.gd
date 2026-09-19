extends Control

@onready var candy_capsule = $CandyCapsule
@onready var balls = $CandyCapsule/Balls
@onready var click_button = $CandyCapsule/ClickButton

@onready var music = $Shop

@onready var flash = $Flash
@onready var big_balls = $BigBalls
@onready var instruction = $Instruction

@onready var fortune_note = $FortuneNote
@onready var fortune_text = $FortuneNote/FortuneText

@onready var zodiac = $ZodiacCharacter
@onready var next_customer = $Next_Customer


var capsule_start_position := Vector2.ZERO

var movement_time := 0.0
var balls_moving := true
var machine_clicked := false

var selected_big_ball: TextureButton
var current_zodiac: Sprite2D


var ball_start_positions = {}
var ball_offsets = {}
var ball_speed_x = {}
var ball_speed_y = {}
var ball_move_x = {}
var ball_move_y = {}


var fortunes = [
	"Good luck is already finding you.",
	"A happy surprise is closer than you think.",
	"Your patience will soon be rewarded.",
	"A new opportunity will appear soon.",
	"Trust the path you are creating.",
	"Something you wished for will begin to grow.",
	"Your courage will open a new door.",
	"A kind person will bring you good news.",
	"September will bring exciting new ventures and opportunities.",
	"Your creativity will lead you somewhere exciting.",
	"You will soon bring joy to someone.",
	"You will spend many years in comfort and material wealth.",
	"You will receive money from an unexpected source.",
	"Your golden opportunity is coming shortly.",
	"You will find your solution when you least expect it.",
	"You will have much to be thankful for in the coming year.",
	"A wise person will give you timely advice.",
	"Your luck stat has increased by +10.",
	"Someone owes you bubble tea.",
	"Someone will do your assignment for you.",
	"Your Professor will have a sick day.",
	"You will have a day off soon.",
	"Go buy yourself a poutine for a lucky day.",
	"Grab something green for good luck.",
	"In two days, your tomorrow will be yesterday.",
	"You will be hungry again in 30 minutes.",
	"Your friend will inherit loads of money. Stay their friend.",
	"You are closer to your dream than yesterday.",
	"You will overcome difficult times.",
	"Support literacy, buy fortune cookies.",
	"An alien of some kind will be appearing to you shortly.",
	"A small choice will bring a big result."
]


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	music.play()

	capsule_start_position = candy_capsule.position

	# Hide things at start
	next_customer.visible = false
	flash.visible = false
	fortune_note.visible = false
	zodiac.visible = false

	instruction.visible = true
	instruction.text = "Click the candy machine to draw your fortune"

	# Connect Next Customer button
	if not next_customer.pressed.is_connected(_on_next_customer_pressed):
		next_customer.pressed.connect(_on_next_customer_pressed)

	# Hide all big capsules and connect them
	for big_ball in big_balls.get_children():

		if big_ball is TextureButton:
			big_ball.visible = false

			var callable = _on_big_ball_pressed.bind(big_ball)

			if not big_ball.pressed.is_connected(callable):
				big_ball.pressed.connect(callable)

	# Prepare little balls inside machine
	for ball in balls.get_children():

		ball_start_positions[ball] = ball.position
		ball_offsets[ball] = randf_range(0.0, 10.0)

		ball_speed_x[ball] = randf_range(3.0, 6.0)
		ball_speed_y[ball] = randf_range(3.0, 6.0)

		ball_move_x[ball] = randf_range(3.0, 7.0)
		ball_move_y[ball] = randf_range(3.0, 7.0)

	# Connect candy machine button
	if not click_button.pressed.is_connected(_on_click_button_pressed):
		click_button.pressed.connect(_on_click_button_pressed)

	setup_zodiac()


func _process(delta: float) -> void:
	if balls_moving:
		movement_time += delta
		move_small_balls()


func move_small_balls() -> void:
	for ball in balls.get_children():

		var start: Vector2 = ball_start_positions[ball]
		var offset: float = ball_offsets[ball]

		var move_x = sin(
			movement_time * ball_speed_x[ball] + offset
		) * ball_move_x[ball]

		var move_y = cos(
			movement_time * ball_speed_y[ball] + offset
		) * ball_move_y[ball]

		ball.position = start + Vector2(
			move_x,
			move_y
		)


func _on_click_button_pressed() -> void:
	print("MACHINE CLICKED")

	if machine_clicked:
		return

	machine_clicked = true
	click_button.disabled = true

	instruction.text = "Drawing your fortune..."

	await shake_machine()
	await white_flash()

	balls_moving = false

	candy_capsule.visible = false

	choose_random_big_ball()

	instruction.text = "Click the capsule to open your fortune"


func shake_machine() -> void:
	for i in range(18):

		candy_capsule.position = capsule_start_position + Vector2(
			randf_range(-10.0, 10.0),
			randf_range(-6.0, 6.0)
		)

		await get_tree().create_timer(0.04).timeout

	candy_capsule.position = capsule_start_position


func white_flash() -> void:
	flash.visible = true
	flash.modulate.a = 0.0

	var tween = create_tween()

	tween.tween_property(
		flash,
		"modulate:a",
		1.0,
		0.12
	)

	tween.tween_property(
		flash,
		"modulate:a",
		0.0,
		0.35
	)

	await tween.finished

	flash.visible = false


func choose_random_big_ball() -> void:
	var choices: Array[TextureButton] = []

	for child in big_balls.get_children():

		if child is TextureButton:
			choices.append(child)

	if choices.is_empty():
		print("NO BIG BALLS FOUND")
		return

	selected_big_ball = choices.pick_random()

	for big_ball in choices:
		big_ball.visible = false

	selected_big_ball.visible = true
	selected_big_ball.disabled = false

	var final_scale = selected_big_ball.scale

	selected_big_ball.pivot_offset = (
		selected_big_ball.size / 2.0
	)

	selected_big_ball.scale = (
		final_scale * 0.1
	)

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		selected_big_ball,
		"scale",
		final_scale,
		0.5
	)


func _on_big_ball_pressed(big_ball: TextureButton) -> void:
	if big_ball != selected_big_ball:
		return

	selected_big_ball.disabled = true

	instruction.text = "Opening your fortune..."

	await shake_big_ball()

	# Second flash
	await white_flash()

	show_fortune()


func shake_big_ball() -> void:
	if selected_big_ball == null:
		return

	var start_position = selected_big_ball.position

	for i in range(14):

		selected_big_ball.position = (
			start_position
			+ Vector2(
				randf_range(-8.0, 8.0),
				randf_range(-5.0, 5.0)
			)
		)

		await get_tree().create_timer(0.04).timeout

	selected_big_ball.position = start_position


func setup_zodiac() -> void:
	# Hide every animal
	for animal in zodiac.get_children():

		if animal is Sprite2D:
			animal.visible = false

	match Global.zodiac_animal:

		"Snake":
			current_zodiac = $ZodiacCharacter/Snake

		"Horse":
			current_zodiac = $ZodiacCharacter/Horse

		"Ox":
			current_zodiac = $ZodiacCharacter/Ox

		"Goat":
			current_zodiac = $ZodiacCharacter/Goat

		"Rat":
			current_zodiac = $ZodiacCharacter/Rat

		"Rabbit":
			current_zodiac = $ZodiacCharacter/Rabbit

		"Tiger":
			current_zodiac = $ZodiacCharacter/Tiger

		"Rooster":
			current_zodiac = $ZodiacCharacter/Rooster

		"Pig":
			current_zodiac = $ZodiacCharacter/Pig

		"Dog":
			current_zodiac = $ZodiacCharacter/Dog

		"Monkey":
			current_zodiac = $ZodiacCharacter/Monkey

		"Dragon":
			current_zodiac = $ZodiacCharacter/Dragon

	if current_zodiac == null:
		print(
			"NO ZODIAC FOUND: ",
			Global.zodiac_animal
		)
		return

	current_zodiac.visible = false


func show_fortune() -> void:
	var chosen_fortune = fortunes.pick_random()

	fortune_text.text = chosen_fortune

	# Hide big capsule
	if selected_big_ball != null:
		selected_big_ball.visible = false

	# Show note exactly where it is in editor
	fortune_note.visible = true

	# Show chosen zodiac exactly where it is in editor
	if current_zodiac != null:
		zodiac.visible = true
		current_zodiac.visible = true

	instruction.text = "Your fortune has been revealed!"

	# Show Next Customer button
	next_customer.visible = true


func _on_next_customer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
