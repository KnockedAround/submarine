extends Area2D

var can_shoot: bool = true
var is_shooting: bool = false
var velocity: Vector2 = Vector2.ZERO

var state: int = states.DEFAULT
enum states {
	DEFAULT,
	O2_REFILL,
	PEOPLE_OFFLOAD,
	PAUSED
}

const ANIMATION_DEFAULT: String = "default"
const ANIMATION_FLASH: String = "flash"
const BULLET_OFFSET: int = 7
const MAX_X_POS: int = 248
const MIN_X_POS: int = 13
const MAX_Y_POS: int = 205
const MIN_Y_POS: int = OXYGEN_REFILL_Y_POS
const OXYGEN_DECREASE_SPEED: int = 5
const OXYGEN_INCREASE_SPEED: int = 60
const OXYGEN_REFILL_SURFACING_SPEED: int = 70
const OXYGEN_REFILL_Y_POS: int = 38
const PIECE_COUNT: int = 10
const ROTATION_STRENGTH: int = 15
const SPEED: Vector2 = Vector2(125, 90)

# Scene
@onready var ReloadTimer := $ReloadTimer
@onready var Sprite := $AnimatedSprite2D
@onready var DecreasePeopleTimer := $DecreasePeopleTimer

# Objects
const Bullet := preload("res://player/player-bullet/player_bullet.tscn")
const ObjectPiece := preload("res://particles/object-piece/object_piece.tscn")

# Textures
const PieceTexture := preload("res://player/player_pieces.png")

# Sounds
const DeathSound := preload("res://player/player_death.ogg")
const OxygenFullSound := preload("res://user-interface/oxygen-bar/full_oxygen_alert.ogg")
const ShootSound := preload("res://player/player-bullet/player_shoot.ogg")

func _ready():
	GameEvent.connect(Signals.full_crew_refuel, Callable(self, "_on_full_crew_refuel"))
	GameEvent.connect(Signals.early_refuel, Callable(self, "_on_early_refuel"))
	GameEvent.connect(Signals.game_over, Callable(self, "_on_game_over"))

func _process(_delta):
	if state == states.DEFAULT:
		process_movement_input()
		direction_follows_input()
		process_shooting()
		lose_oxygen()
		death_on_no_oxygen()
	elif state == states.O2_REFILL:
		oxygen_refill()
		move_to_surface()
	elif state == states.PEOPLE_OFFLOAD:
		move_to_surface()
	
	clamp_position()
	GameEvent.emit_signal(Signals.camera_follow_player, global_position.y)


func _physics_process(_delta):
	if state == states.DEFAULT:
		movement()
		rotate_to_movement()

func _on_full_crew_refuel():
	Sprite.play(ANIMATION_FLASH)
	GameEvent.emit_signal(Signals.pause_enemies, true)
	GameEvent.emit_signal(Signals.kill_all_enemies)
	state = states.PEOPLE_OFFLOAD
	DecreasePeopleTimer.start()
	death_when_refill_on_full()
	
func _on_early_refuel():
	Sprite.play(ANIMATION_FLASH)
	GameEvent.emit_signal(Signals.pause_enemies, true)
	state = states.O2_REFILL
	if Global.saved_people_count > 0:
		remove_one_person()
	death_when_refill_on_full()

func process_movement_input():
	velocity.x = Input.get_axis(ActionMap.move_left, ActionMap.move_right)
	velocity.y = Input.get_axis(ActionMap.move_up, ActionMap.move_down)
	
	velocity = velocity.normalized()

func rotate_to_movement():
	var rotation_target = 0
	if velocity.y == 0:
		rotation_target = velocity.x * ROTATION_STRENGTH
	else:
		if not Sprite.flip_h:
			rotation_target = velocity.y * ROTATION_STRENGTH
		else:
			rotation_target = -velocity.y * ROTATION_STRENGTH
	
	rotation_degrees = lerp(rotation_target, rotation_target, ROTATION_STRENGTH * get_physics_process_delta_time())

func direction_follows_input():
	if is_shooting:
		return 
	
	if velocity.x > 0:
		Sprite.flip_h = false
	elif velocity.x < 0:
		Sprite.flip_h = true

func process_shooting():
	if Input.is_action_pressed(ActionMap.shoot) and can_shoot:
		var bullet_instance = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet_instance)
		
		SoundManager.play_sound(ShootSound)
		
		if Sprite.flip_h == true:
			bullet_instance.flip_direction()
			bullet_instance.global_position = global_position - Vector2(BULLET_OFFSET, 0)
		else:
			bullet_instance.global_position = global_position + Vector2(BULLET_OFFSET, 0)
		
		ReloadTimer.start()
		can_shoot = false
	if Input.is_action_pressed(ActionMap.shoot):
		is_shooting = true
	else:
		is_shooting = false

func lose_oxygen():	
	Global.oxygen_level = move_toward(
		Global.oxygen_level, 
		0, 
		OXYGEN_DECREASE_SPEED * get_process_delta_time()
	)

func oxygen_refill():
	Global.oxygen_level += OXYGEN_INCREASE_SPEED * get_process_delta_time()
	
	
	if Global.oxygen_level > 99:
		state = states.DEFAULT
		Sprite.play(ANIMATION_DEFAULT)
		GameEvent.emit_signal(Signals.pause_enemies, false)
		SoundManager.play_sound(OxygenFullSound)
		
func death_on_no_oxygen():
	if Global.oxygen_level <= 0:
		death()
		
func death_when_refill_on_full():
	if Global.oxygen_level > 90:
		death()
		
func death():
	GameEvent.emit_signal(Signals.game_over)
	GameEvent.emit_signal(Signals.pause_enemies, true)
	SoundManager.play_sound(DeathSound)
	instance_player_pieces()
	
func instance_player_pieces():
	for i in range(PIECE_COUNT):
		var piece_instance = ObjectPiece.instantiate()
		piece_instance.texture = PieceTexture
		piece_instance.hframes = PIECE_COUNT
		piece_instance.frame = i
		get_tree().current_scene.add_child(piece_instance)
		piece_instance.global_position = global_position

func movement():
	global_position += velocity * SPEED * get_physics_process_delta_time()
	
func clamp_position():
	global_position.x = clamp(global_position.x, MIN_X_POS, MAX_X_POS)
	global_position.y = clamp(global_position.y, MIN_Y_POS, MAX_Y_POS)

func _on_reload_timer_timeout():
	can_shoot = true

func move_to_surface():
	var move_speed = OXYGEN_REFILL_SURFACING_SPEED * get_process_delta_time()
	rotation_degrees = lerp(rotation_degrees, 0.0, ROTATION_STRENGTH * get_physics_process_delta_time())
	global_position.y = move_toward(global_position.y, OXYGEN_REFILL_Y_POS, move_speed)

func _on_decrease_people_timer_timeout():
	remove_one_person()
	if Global.saved_people_count <= 0:
		state = states.O2_REFILL
		DecreasePeopleTimer.stop()

func _on_game_over():
	queue_free()

func remove_one_person():
	Global.saved_people_count -= 1
	GameEvent.emit_signal(Signals.update_collected_people_count)
