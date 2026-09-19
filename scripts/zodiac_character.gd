extends CharacterBody2D

@onready var progress_bar = get_tree().current_scene.get_node("Progress_Bar/CoinProgress")
@onready var coin_label = get_tree().current_scene.get_node("Progress_Bar/CoinLabel")

var points := 0
var target_score := 10

@export var coin_pickup_distance := 50.0
@export var bomb_hit_distance := 70.0
@export var shake_amount := 2.0
@export var shake_speed := 10.0

var time := 0.0
var current_animal: Sprite2D
var animal_start_position := Vector2.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	coin_label.text = "0 / 10 Coins"
	progress_bar.min_value = 0
	progress_bar.max_value = target_score
	progress_bar.value = 0

	print("Selected animal: ", Global.zodiac_animal)

	# Hide all animals
	$Zodiac/Snake.visible = false
	$Zodiac/Horse.visible = false
	$Zodiac/Ox.visible = false
	$Zodiac/Rat.visible = false
	$Zodiac/Goat.visible = false
	$Zodiac/Rabbit.visible = false
	$Zodiac/Tiger.visible = false
	$Zodiac/Monkey.visible = false
	$Zodiac/Rooster.visible = false
	$Zodiac/Dog.visible = false
	$Zodiac/Pig.visible = false
	$Zodiac/Dragon.visible = false

	# Show selected animal
	if Global.zodiac_animal == "Snake":
		$Zodiac/Snake.visible = true
		current_animal = $Zodiac/Snake

	elif Global.zodiac_animal == "Horse":
		$Zodiac/Horse.visible = true
		current_animal = $Zodiac/Horse

	elif Global.zodiac_animal == "Ox":
		$Zodiac/Ox.visible = true
		current_animal = $Zodiac/Ox

	elif Global.zodiac_animal == "Goat":
		$Zodiac/Goat.visible = true
		current_animal = $Zodiac/Goat

	elif Global.zodiac_animal == "Rat":
		$Zodiac/Rat.visible = true
		current_animal = $Zodiac/Rat

	elif Global.zodiac_animal == "Rabbit":
		$Zodiac/Rabbit.visible = true
		current_animal = $Zodiac/Rabbit

	elif Global.zodiac_animal == "Tiger":
		$Zodiac/Tiger.visible = true
		current_animal = $Zodiac/Tiger

	elif Global.zodiac_animal == "Monkey":
		$Zodiac/Monkey.visible = true
		current_animal = $Zodiac/Monkey

	elif Global.zodiac_animal == "Rooster":
		$Zodiac/Rooster.visible = true
		current_animal = $Zodiac/Rooster

	elif Global.zodiac_animal == "Dog":
		$Zodiac/Dog.visible = true
		current_animal = $Zodiac/Dog

	elif Global.zodiac_animal == "Pig":
		$Zodiac/Pig.visible = true
		current_animal = $Zodiac/Pig

	elif Global.zodiac_animal == "Dragon":
		$Zodiac/Dragon.visible = true
		current_animal = $Zodiac/Dragon

	if current_animal == null:
		push_error("Animal not created yet: " + str(Global.zodiac_animal))
		return

	animal_start_position = current_animal.position


func _physics_process(delta: float) -> void:
	if current_animal == null:
		return

	# FOLLOW MOUSE
	var mouse_position = get_global_mouse_position()
	var screen_size = get_viewport_rect().size

	mouse_position.x = clamp(
		mouse_position.x,
		0.0,
		screen_size.x
	)

	mouse_position.y = clamp(
		mouse_position.y,
		0.0,
		screen_size.y
	)

	global_position = mouse_position

	# SMALL VIBRATION
	time += delta

	var shake_x = sin(time * shake_speed) * shake_amount
	var shake_y = cos(time * shake_speed * 1.2) * shake_amount

	current_animal.position = animal_start_position + Vector2(
		shake_x,
		shake_y
	)

	# COLLECT COINS
	for coin in get_tree().get_nodes_in_group("coins"):
		if global_position.distance_to(coin.global_position) < coin_pickup_distance:
			collect_coin(coin)

	# HIT BOMBS
	for bomb in get_tree().get_nodes_in_group("bombs"):
		if current_animal.global_position.distance_to(bomb.global_position) < bomb_hit_distance:
			hit_bomb(bomb)


func collect_coin(coin: Node) -> void:
	if coin.get_meta("collected", false):
		return

	coin.set_meta("collected", true)

	# Stop counting after 10
	if points < target_score:
		points += 1

	progress_bar.value = points

	if points >= target_score:
		coin_label.text = "Press E to get Fortune"
	else:
		coin_label.text = str(points) + " / " + str(target_score) + " Coins"

	print("POINTS: ", points)

	coin.pickup()

	await get_tree().create_timer(0.3).timeout

	if is_instance_valid(coin):
		coin.queue_free()


func hit_bomb(bomb: Node) -> void:
	if bomb.get_meta("hit", false):
		return

	bomb.set_meta("hit", true)

	print("BOMB HIT!")

	var health = get_tree().current_scene.get_node("Health")

	if health:
		health.take_damage()

	damage_flash()

	bomb.explode()


func damage_flash() -> void:
	if current_animal == null:
		return

	for i in range(3):
		current_animal.modulate.a = 0.25
		await get_tree().create_timer(0.1).timeout

		current_animal.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout

	current_animal.modulate.a = 1.0
