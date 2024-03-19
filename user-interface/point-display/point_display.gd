extends Label


func _ready():
	GameEvent.connect(Signals.update_score, Callable(self, "_on_update_score"))

func _on_update_score():
	text = str(Global.score)
