extends Node

class_name GameVersionController

@export var days_to_demo := 5


func _ready() -> void:
	DayNightCycleController.day_started.connect(on_new_day)


func on_new_day() -> void:
	if not AppManager.is_demo:
		return
	if DayNightCycleController.day_count >= days_to_demo:
		var flow_screen: ScreenFlowManager
		flow_screen = get_tree().get_first_node_in_group("screen_flow_manager")
		flow_screen.load_end_demo_screen()
