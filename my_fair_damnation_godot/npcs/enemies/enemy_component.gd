extends Node3D
class_name EnemyComponent

var enemy : Enemy
var player : Player


func set_up_component(_player : Player, _enemy : Enemy) -> void:
	enemy = _enemy
	player = _player



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
