extends Sprite2D

@export var order_number: int = 1

const EMPTY_TEXTURE := preload("res://user-interface/people-count/person_empty_ui.png")
const FULL_TEXTURE := preload("res://user-interface/people-count/person_ui.png")


func _ready():
	GameEvent.connect(Signals.update_collected_people_count, Callable(self, "_on_update_collected_people_count"))

func _on_update_collected_people_count():
	if Global.saved_people_count >= 7:
		frame = 1
	else:
		frame = 0
		
	if Global.saved_people_count >= order_number:
		texture = FULL_TEXTURE
	else: 
		texture = EMPTY_TEXTURE
	
