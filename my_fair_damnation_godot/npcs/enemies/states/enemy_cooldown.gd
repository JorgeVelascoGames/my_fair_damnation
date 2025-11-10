extends EnemyState
class_name EnemyCooldown

@export var cooldown_duration := 4.0


func enter(_msg = {}) -> void:
	enemy_animator_controller.play_cooldown_animation()
	enemy.enemy_navigation.stop()
	enemy.velocity = Vector3.ZERO
	await get_tree().create_timer(cooldown_duration).timeout
	state_machine.transition_to("EnemyChasing", {})
 
