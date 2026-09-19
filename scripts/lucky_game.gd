extends Node2D

var coin_scene = preload("res://scenes/coin.tscn")

var spawn_timer := 0.0
var spawn_delay := 1.0

func _process(delta: float) -> void:
	spawn_timer -= delta

	if spawn_timer <= 0:
		spawn_coin()
		spawn_timer = spawn_delay

func spawn_coin() -> void:
	var coin = coin_scene.instantiate()
	add_child(coin)

	coin.position = Vector2(
		randf_range(100.0, 1180.0),
		-50.0
	)
