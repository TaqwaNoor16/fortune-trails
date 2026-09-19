extends TextureRect

@export var move_speed := 50.0

func _process(delta: float) -> void:
	position.x += move_speed * delta

	# When the cloud is completely off the right side
	if position.x > get_viewport_rect().size.x:
		position.x = -size.x
