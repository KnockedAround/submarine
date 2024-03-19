extends Area2D

var velocity = Vector2.RIGHT
var points_value = 30
const SPEED = 25
var state = states.DEFAULT
enum states { DEFAULT, PAUSED }
const SaveSound = preload("res://person/saving_person.ogg")
const DeathSound = preload("res://person/person_death.ogg")
const PointValuePopup = preload("res://user-interface/points-value-popup/point_value_popup.tscn")
@onready var Sprite = $AnimatedSprite2D
func _ready():
	GameEvent.connect("pause_enemies", Callable(self, "_on_pause_enemies"))
	
func _physics_process(delta):
	if state == states.DEFAULT:
		global_position += velocity * SPEED * delta

func _process(_delta):
	if global_position.x > Global.SCREEN_BOUND_MAX_X or global_position.x < Global.SCREEN_BOUND_MIN_X:
		queue_free()

func flip_direction():
	velocity = -velocity
	Sprite.flip_h = !Sprite.flip_h

func _on_area_entered(area):
	if area.is_in_group("Player") and Global.saved_people_count < 7:
		Global.saved_people_count += 1
		GameEvent.emit_signal("update_collected_people_count")
		Global.score += points_value
		GameEvent.emit_signal("update_score")
		
		SoundManager.play_sound(SaveSound)
		instance_point_value_popup()
		queue_free()
	elif area.is_in_group("PlayerBullet"):
		SoundManager.play_sound(DeathSound)
		area.queue_free()
		queue_free()

func instance_point_value_popup():
	var pvp_instance = PointValuePopup.instantiate()
	pvp_instance.value = points_value
	get_tree().current_scene.add_child(pvp_instance)
	
	pvp_instance.global_position = global_position
	
func _on_pause_enemies(pause):
	if pause:
		state = states.PAUSED
	else:  
		state = states.DEFAULT
