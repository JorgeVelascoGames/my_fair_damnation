extends NpcComponent
class_name NpcDayNight

#This node propagates the day/night signals across the 
#other NpcComponent nodes


func _ready() -> void:
	DayNightCycleController.day_started.connect(_on_day_start)
	DayNightCycleController.night_started.connect(_on_night_start)
	DayNightCycleController.player_sleeps_all_night.connect(_on_sleep_all_night)


func _on_day_start() -> void:
	for node in npc.get_children():
		if node is NpcComponent:
			node.on_day_start()


func _on_night_start() -> void:
	for node in npc.get_children():
		if node is NpcComponent:
			node.on_night_start()


func _on_sleep_all_night() -> void:
	for node in npc.get_children():
		if node is NpcComponent:
			node.on_sleep_all_night()
