extends Control



@onready var year_input = $LineEdit
@onready var result_label = $Label

var animals = [
	"Rat",
	"Ox",
	"Tiger",
	"Rabbit",
	"Dragon",
	"Snake",
	"Horse",
	"Goat",
	"Monkey",
	"Rooster",
	"Dog",
	"Pig"
]

func _on_claim_my_fate_pressed() -> void:
	var text = year_input.text.strip_edges()

	if text.is_empty() or not text.is_valid_int():
		result_label.text = "Please enter a valid birthday year!"
		return

	var birth_year = int(text)

	if birth_year < 1960:
		result_label.text = "Please enter a year from 1960 onwards."
		return

	var animal = animals[(birth_year - 1960) % 12]

	print("Birth year: ", birth_year)
	print("Your zodiac animal: ", animal)

	Global.zodiac_animal = animal

	get_tree().change_scene_to_file("res://scenes/lucky_game.tscn")
