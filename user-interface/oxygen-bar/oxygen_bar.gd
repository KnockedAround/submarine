extends Node2D

const AlertSound := preload("res://user-interface/oxygen-bar/oxygen_alert.ogg")

@onready var TextureProgress := $TextureProgress
@onready var FlashTimer := $FlashTimer
var previous_amount: float = 0
func _process(_delta):
	TextureProgress.value = Global.oxygen_level
	
	var amount_rounded = round(Global.oxygen_level)
	
	if amount_rounded == previous_amount:
		return
	
	if amount_rounded == 25:
		scale_and_rotate(1.25, 5)
	elif amount_rounded == 15:
		scale_and_rotate(1.3, 7)
	elif amount_rounded == 10:
		scale_and_rotate(1.35, 9)
	elif amount_rounded == 7:
		scale_and_rotate(1.4, 11)
	elif amount_rounded == 5:
		scale_and_rotate(1.45, 13)
	elif amount_rounded == 2:
		scale_and_rotate(1.5, 15)
	elif amount_rounded == 1:
		scale_and_rotate(1.55, 17)
	
	previous_amount = amount_rounded
	
	
func _physics_process(delta):
	scale = lerp(scale, Vector2(1, 1,), 6 * delta)
	rotation_degrees = lerp(rotation_degrees, 0.0, 6 * delta)

func scale_and_rotate(scale_factor, degrees):
	scale = Vector2(scale_factor, scale_factor)
	rotation_degrees = randf_range(-degrees, degrees)
	modulate = Color(50, 50, 50)
	FlashTimer.start()
	SoundManager.play_sound(AlertSound)
	
func _on_flash_timer_timeout():
	modulate = Color(1,1,1)
