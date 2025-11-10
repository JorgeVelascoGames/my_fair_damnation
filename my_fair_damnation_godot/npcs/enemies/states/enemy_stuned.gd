extends EnemyState
class_name EnemyStuned

@export var stun_duration := 3.0


func enter(_msg = {}) -> void:
	enemy_animator_controller.play_stun_animation()
	enemy.enemy_navigation.stop()
	enemy.enemy_detection.stop_detection()
	await get_tree().create_timer(stun_duration).timeout
	enemy.enemy_detection.force_lose_player()
	state_machine.transition_to("EnemyIdle", {})


func exit() -> void:
	enemy.enemy_detection.start_detection()
