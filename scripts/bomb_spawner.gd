extends Node2D

var bomb_scene = preload("res://scenes/bomb.tscn")

var spawn_timer := 0.0
var spawn_delay := 3.0


func _process(delta: float) -> void:
	spawn_timer -= delta

	if spawn_timer <= 0.0:
		spawn_bomb()
		spawn_timer = spawn_delay


func spawn_bomb() -> void:
	var bomb = bomb_scene.instantiate()
	add_child(bomb)

	var screen_size = get_viewport_rect().size

	bomb.position = Vector2(
		randf_range(50.0, screen_size.x - 50.0),
		-50.0
	)
