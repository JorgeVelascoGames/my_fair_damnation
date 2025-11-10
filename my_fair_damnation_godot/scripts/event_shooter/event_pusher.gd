extends Node


func _ready() -> void:
	DayNightCycleController.day_started.connect(on_day_started)
	DayNightCycleController.night_started.connect(on_night_started)
	EventManager.new_event_pushed.connect(on_event)


func on_day_started() -> void:
	pass


func on_night_started() -> void:
	pass


func on_event(event : Event) -> void:
	pass
