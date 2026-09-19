extends Area2D

@onready var zodiac_character = $"../ZodiacCharacter"
@onready var balls = $Balls
@onready var sparkles = $Sparkles/Sparkles

var activated := false

var movement_time := 0.0

var ball_start_positions = {}
var ball_offset = {}
var ball_speed_x = {}
var ball_speed_y = {}
var ball_move_x = {}
var ball_move_y = {}

var sparkle_tween: Tween


func _ready() -> void:
	# Machine starts grey
	$AnimatedSprite2D.modulate = Color(0.4, 0.4, 0.4)

	# Sparkles hidden
	sparkles.modulate.a = 0.0

	# Balls start grey
	for ball in balls.get_children():
		ball.modulate = Color(0.4, 0.4, 0.4)

		ball_start_positions[ball] = ball.position
		ball_offset[ball] = randf_range(0.0, 10.0)

		ball_speed_x[ball] = randf_range(2.0, 4.0)
		ball_speed_y[ball] = randf_range(2.0, 4.0)

		ball_move_x[ball] = randf_range(3.0, 8.0)
		ball_move_y[ball] = randf_range(3.0, 8.0)


func _process(delta: float) -> void:

	# Reach 10 coins
	if zodiac_character.points >= 10 and !activated:
		activate_machine()

	# Move balls after activation
	if activated:
		movement_time += delta
		move_balls()

	# Press E ANYWHERE after activation
	if activated and Input.is_action_just_pressed("interact"):
		print("GOING TO FORTUNE REVEAL")

		get_tree().change_scene_to_file(
			"res://scenes/fortune_reveal.tscn"
		)


func activate_machine() -> void:
	activated = true

	# Machine becomes colorful
	$AnimatedSprite2D.modulate = Color.WHITE
	$AnimatedSprite2D.play("Press")

	# Balls become colorful
	for ball in balls.get_children():
		ball.modulate = Color.WHITE

	start_sparkles()


func move_balls() -> void:
	for ball in balls.get_children():

		var start: Vector2 = ball_start_positions[ball]
		var offset: float = ball_offset[ball]

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


func start_sparkles() -> void:
	if sparkle_tween:
		sparkle_tween.kill()

	sparkles.modulate.a = 0.2

	sparkle_tween = create_tween()
	sparkle_tween.set_loops()

	# Bright
	sparkle_tween.tween_property(
		sparkles,
		"modulate:a",
		1.0,
		0.7
	)

	# Dim
	sparkle_tween.tween_property(
		sparkles,
		"modulate:a",
		0.2,
		0.7
	)
