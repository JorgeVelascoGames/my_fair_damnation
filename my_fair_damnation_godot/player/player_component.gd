extends Node
class_name PlayerComponent

@onready var player : Player = owner


func on_event_pushed(event : Event) -> void:
	pass


func on_event_finished(event: Event) -> void:
	pass


func on_event_triggered(event : Event) -> void:
	pass


func on_day_start() -> void:
	pass


func on_night_start() -> void:
	pass


func on_sleep_all_night() -> void:
	pass
