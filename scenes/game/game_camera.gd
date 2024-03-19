extends Camera2D

const FOLLOW_SPEED: int = 9
const MIN_Y_POS: int = 70
const MAX_Y_POS: int = 145

var target_position: Vector2 = global_position

func _ready():
	GameEvent.connect(Signals.camera_follow_player, Callable(self, "_on_follow_player"))
	
func _physics_process(delta):
	global_position.y = lerp(global_position.y, target_position.y, FOLLOW_SPEED * delta)

func _on_follow_player(player_y):
	target_position.y = clamp(player_y, MIN_Y_POS, MAX_Y_POS)
