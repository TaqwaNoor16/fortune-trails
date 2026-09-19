extends Control

var health := 3


func take_damage() -> void:
	if health <= 0:
		return

	var heart = get_node("Hearts/Heart" + str(health))

	heart.play("lose_health")

	health -= 1

	await heart.animation_finished

	heart.visible = false

	if health <= 0:
		game_over()


func game_over() -> void:
	print("GAME OVER")

	# Bring normal mouse cursor back
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Make sure game isn't still paused
	get_tree().paused = false

	get_tree().change_scene_to_file("res://scenes/main.tscn")
