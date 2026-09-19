extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_sound: AudioStreamPlayer2D = $Explosion

var fall_speed := 200.0
var exploded := false


func _process(delta: float) -> void:
	if exploded:
		return

	position.y += fall_speed * delta

	# Delete bomb if it falls off screen
	if global_position.y > get_viewport_rect().size.y + 100:
		queue_free()


func explode() -> void:
	if exploded:
		return

	exploded = true
	fall_speed = 0.0

	# Stop collision immediately
	$CollisionShape2D.set_deferred("disabled", true)

	# Play blast animation
	$AnimatedSprite2D.play("blast")

	# Play explosion sound
	$Explosion.play()

	# Wait until animation reaches the explosion frame
	await $AnimatedSprite2D.animation_finished

	# KEEP the final 💥 frame visible
	$AnimatedSprite2D.pause()

	await get_tree().create_timer(0.4).timeout

	# Stop the long sound
	$Explosion.stop()

	queue_free()
