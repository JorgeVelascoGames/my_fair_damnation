extends PlayerComponent
class_name PlayerDayNight

## This class manages the players behaviour arround the day/night cycle mechanic


func _ready() -> void:
	DayNightCycleController.day_started.connect(_on_day_start)
	DayNightCycleController.night_started.connect(_on_night_start)
	DayNightCycleController.player_sleeps_all_night.connect(_on_sleep_all_night)


func _on_day_start() -> void:
	for node in player.get_children():
		if node is PlayerComponent:
			node.on_day_start()


func _on_night_start() -> void:
	for node in player.get_children():
		if node is PlayerComponent:
			node.on_night_start()


func _on_sleep_all_night() -> void:
	for node in player.get_children():
		if node is PlayerComponent:
			node.on_sleep_all_night()
