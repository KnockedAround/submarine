extends Node2D

@onready var LeftSpawnContainer := $LeftSpawnContainer
@onready var RightSpawnContainer := $RightSpawnContainer
@onready var SpawnEnemyTimer := $SpawnEnemyTimer
@onready var SpawnPersonTimer := $SpawnPersonTimer

const Shark := preload("res://enemies/shark/shark.tscn")
const Person := preload("res://person/person.tscn")

var used_spawn_points = []

func _ready():
	GameEvent.connect(Signals.pause_enemies, Callable(self, "_on_pause_enemies"))

#new wave spawned
func _on_spawn_enemy_timer_timeout():
	for i in range(4):
		spawn_enemy()
	
	used_spawn_points.clear()

#spawn one enemy
func spawn_enemy():
	var available_spawn_points = []
	
	for i in range(1, 5):
		if !used_spawn_points.has(i):
			available_spawn_points.append(i)
	
	var rand_spawn_point_index = randi_range(0, available_spawn_points.size() - 1)
	var selected_spawn_point_number = available_spawn_points[rand_spawn_point_index]
	used_spawn_points.append(selected_spawn_point_number)
	
	var selected_side_node = LeftSpawnContainer
	var spawn_right = bool(randi_range(0, 1))
	
	if spawn_right == true:
		selected_side_node = RightSpawnContainer
	
	var selected_spawn_point = selected_side_node.get_node(str(selected_spawn_point_number))
	var spawn_position = selected_spawn_point.global_position
	
	var shark_instance = Shark.instantiate()
	shark_instance.global_position = spawn_position
	get_tree().current_scene.add_child(shark_instance)

	if spawn_right == true:
		shark_instance.flip_direction()


func _on_spawn_person_timer_timeout():
	var person_instance = Person.instantiate()
	get_tree().current_scene.add_child(person_instance)

	var selected_spawn_point_number = randi_range(1, 4)
	
	var selected_side_node = LeftSpawnContainer
	var spawn_right = bool(randi_range(0, 1))
	
	if spawn_right == true:
		selected_side_node = RightSpawnContainer
	
	var selected_spawn_point = selected_side_node.get_node(str(selected_spawn_point_number))
	var spawn_position = selected_spawn_point.global_position
	
	person_instance.global_position = spawn_position
	
	if spawn_right == true:
		person_instance.flip_direction()

func _on_pause_enemies(pause):
	if pause:
		SpawnEnemyTimer.stop()
		SpawnPersonTimer.stop()
	elif !pause:
		SpawnEnemyTimer.start()
		SpawnPersonTimer.start()
