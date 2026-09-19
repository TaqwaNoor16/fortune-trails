extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var fall_speed := 200.0


func _process(delta: float) -> void:
	position.y += fall_speed * delta

	# Remove coin when it leaves the bottom of the screen
	if global_position.y > get_viewport_rect().size.y + 50:
		queue_free()


func pickup() -> void:
	animation_player.play("pickup")
