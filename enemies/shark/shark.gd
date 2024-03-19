extends Area2D

const SPEED: int  = 50
const X_STRETCH_FACTOR: float = 0.15
const AMPLITUDE_SCALE: float = 0.5
const DeathSound := preload("res://enemies/shark/shark_death.ogg")
const ObjectPiece := preload("res://particles/object-piece/object_piece.tscn")
const PointValuePopup := preload("res://user-interface/points-value-popup/point_value_popup.tscn")
const PIECE_COUNT: int = 2

var velocity: Vector2 = Vector2(1, 0)
var random_offset: float = randf_range(0, 10)
var point_value: int = 25
var state: states = states.DEFAULT
enum states { DEFAULT, PAUSED }

@onready var Sprite := $AnimatedSprite2D

func _ready():
	GameEvent.connect(Signals.pause_enemies, Callable(self, "_on_pause_enemies"))
	GameEvent.connect(Signals.kill_all_enemies, Callable(self, "_on_death"))

func _physics_process(delta):
	if state == states.DEFAULT:
		velocity.y = sin(global_position.x * X_STRETCH_FACTOR + random_offset) * AMPLITUDE_SCALE
		global_position += velocity * SPEED * delta

func _process(_delta):
	if global_position.x > Global.SCREEN_BOUND_MAX_X or global_position.x < Global.SCREEN_BOUND_MIN_X:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group(Groups.PlayerBullet):
		area.queue_free()
		_on_death()
		
	if area.is_in_group(Groups.Player):
		area.death()
		
func instance_point_popup():
	var pvp = PointValuePopup.instantiate()
	pvp.value = point_value
	get_tree().current_scene.add_child(pvp)
	
	pvp.global_position = global_position
	
func instance_death_pieces():
	for i in range(PIECE_COUNT):
		var piece_instance = ObjectPiece.instantiate()
		piece_instance.frame = i
		get_tree().current_scene.add_child(piece_instance)
		
		piece_instance.global_position = global_position
	
func _on_pause_enemies(pause):
	if pause:
		state = states.PAUSED
	else: 
		state = states.DEFAULT

func flip_direction():
	velocity = -velocity
	Sprite.flip_h = !Sprite.flip_h

func _on_death():
	Global.score += point_value
	GameEvent.emit_signal(Signals.update_score)
	SoundManager.play_sound(DeathSound)
	instance_death_pieces()
	instance_point_popup()
	queue_free()
