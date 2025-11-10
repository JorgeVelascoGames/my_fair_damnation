extends Node3D
class_name FrankEnemiesController

@export var hunt_time := 100.00
@export var frank_npc : Npc
@export var frank_instance_to_block_spawn : NpcInstance

@onready var frank_enemies_timer: Timer = $FrankEnemiesTimer

var frank_list : Array[EnemySpawner] = []


func _ready() -> void:
	for frank in get_children():
		if frank is EnemySpawner:
			frank_list.append(frank)
	
	DayNightCycleController.day_started.connect(_on_day)
	DayNightCycleController.night_started.connect(_on_night)
	for frank in frank_list:
		frank.enemy_to_spawn.enemy_detection.found_player.connect(on_player_detected)
		frank.despawn()


func on_player_detected() -> void:
	frank_enemies_timer.stop()
	await get_tree().process_frame
	for frank in frank_list:
		if not frank.enemy_to_spawn.enemy_detection.is_player_tracked:
			frank.despawn()
			if frank.enemy_to_spawn.enemy_detection.found_player.is_connected(on_player_detected):
				frank.enemy_to_spawn.enemy_detection.found_player.disconnect(on_player_detected)


func _on_night() -> void:
	await get_tree().create_timer(2).timeout
	
	if frank_npc.npc_instance_controller.active_instance == frank_instance_to_block_spawn:
		return
	
	for frank in frank_list:
		frank.enemy_to_spawn.enemy_detection.found_player.connect(on_player_detected)
	frank_list.shuffle()
	frank_list[1].spawn()
	frank_list[2].spawn()
	frank_list[3].spawn()
	frank_list[4].spawn()
	frank_enemies_timer.start(hunt_time)


func _on_day() -> void:
	for frank in frank_list:
		frank.despawn()


func _on_frank_enemies_timer_timeout() -> void:
	frank_list[1].enemy_to_spawn.enemy_detection.player_found()


func _load(_data : SavedData) -> void:
	if _data.day_night_period == DayNightCycleController.NIGHT: ## This doesn't take in account if it's on doom period, but honestly idgaf
		_on_night()
		frank_list[1].enemy_to_spawn.enemy_detection.player_found()
