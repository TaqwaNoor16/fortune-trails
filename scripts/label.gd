extends Label

@export var float_height := 7.0
@export var float_speed := 3

var start_position: Vector2
var time := 0.0


func _ready() -> void:
	start_position = position


func _process(delta: float) -> void:
	time += delta
	
	position.y = start_position.y + sin(time * float_speed) * float_height
