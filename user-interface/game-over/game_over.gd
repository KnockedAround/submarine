extends Control

@onready var ScoreLabel := $ScoreLabel
@onready var HighScoreLabel := $HighScoreLabel
@onready var GameOverDelayTimer := $GameOverDelayTimer

const GameOverSound := preload("res://player/game_over.ogg")

func _ready():
	GameEvent.connect(Signals.game_over, Callable(self, "_on_game_over"))
	visible = false

func _on_game_over():
	ScoreLabel.text = "score " + str(Global.score)
	
	if Global.score > Global.highscore:
		Global.highscore = Global.score
	
	HighScoreLabel.text = "Highscore " + str(Global.highscore)
	GameOverDelayTimer.start()

func _on_game_over_delay_timeout():
	visible = true
	SoundManager.play_sound(GameOverSound)
	
func _process(_delta):
	if Input.is_action_just_pressed(ActionMap.shoot) and visible:
		Global.reset_state()
		get_tree().reload_current_scene()
