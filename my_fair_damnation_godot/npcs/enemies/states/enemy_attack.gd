extends EnemyState
class_name EnemyAttack

@export var enemy_attack_duration := 2.0

## For the player to look at
@export var camera_look_at : Marker3D

@onready var enemy_navigation: EnemyNavigation = $"../../EnemyNavigation"


func enter(_msg = {}) -> void:
	enemy_animator_controller.play_attack_animation()
	enemy.player.player_state_machine.transition_to("PlayerGrabbed", {"position" : camera_look_at})
	print("Attack!")
	enemy_navigation.avoidance_mask = 0
	enemy.enemy_navigation.stop()
	await get_tree().create_timer(enemy_attack_duration).timeout
	state_machine.transition_to("EnemyCooldown", {})


func exit() -> void:
	enemy_navigation.avoidance_mask = 1
	enemy.player.player_state_machine.transition_to("PlayerIdle", {})
