extends Node

var highscore: int = 0
var oxygen_level: float = 100
var saved_people_count: int = 0
var score: int = 0

const SCREEN_BOUND_MAX_X: int = 300
const SCREEN_BOUND_MIN_X: int = -50

func reset_state():
	saved_people_count = 0
	oxygen_level = 100
	score = 0

func _process(_delta):
	if Input.is_action_pressed(ActionMap.exit):
		get_tree().quit()
