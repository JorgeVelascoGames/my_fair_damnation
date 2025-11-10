extends EnemyState
class_name EnemyIdle


func enter(_msg = {}) -> void:
	enemy_animator_controller.play_idle_animation()
	enemy.enemy_navigation.stop()
	enemy.enemy_detection.found_player.connect(start_chasing)


func start_chasing() -> void:
	state_machine.transition_to("EnemyChasing", {})


func exit() -> void:
	enemy.enemy_detection.found_player.disconnect(start_chasing)
