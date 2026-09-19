extends Sprite2D

@export var fall_speed := 200.0

func _process(delta: float) -> void:
	position.y += fall_speed * delta
