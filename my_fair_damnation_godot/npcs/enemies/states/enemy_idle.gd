extends EnemyState
class_name EnemyIdle

## Delays the start of the chase when detecting player
@export var start_chase_delay := 0.0


func enter(_msg = {}) -> void:
	enemy_animator_controller.play_idle_animation()
	enemy.enemy_navigation.stop()
	enemy.enemy_detection.found_player.connect(start_chasing)


func start_chasing() -> void:
	await get_tree().create_timer(start_chase_delay).timeout
	enemy.enemy_detection.lose_track_timer.stop()
	enemy.enemy_detection.is_player_tracked = true
	state_machine.transition_to("EnemyChasing", {})


func exit() -> void:
	enemy.enemy_detection.found_player.disconnect(start_chasing)
