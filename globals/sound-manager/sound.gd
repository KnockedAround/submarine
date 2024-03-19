extends AudioStreamPlayer

func _ready():
	connect(Signals.finished, Callable(self, "_on_finished"))
	
func _on_finished():
	queue_free()
