extends EnemyState
class_name EnemyChasing

@onready var enemy_navigation: EnemyNavigation = $"../../EnemyNavigation"

@export var chasing_speed := 2.0
@export var chase_when_unseen := false


func enter(_msg = {}) -> void:
	enemy.look_at_y_axis_only(PathfindingManager.player_position)
	enemy.enemy_audio.start_footsteps_chase()
	enemy_animator_controller.play_chase_animation()
	enemy_navigation.avoidance_mask = 1
	enemy.enemy_detection.lose_player_track.connect(lose_track)
	enemy.enemy_detection.player_entered_attack_range.connect(attack)


func update(delta) -> void:
	if not PathfindingManager.player:
		state_machine.transition_to("EnemyIdle", {})
		return
	if can_chase():
		enemy.enemy_navigation.move_to(PathfindingManager.player_position, chasing_speed)
		if chase_when_unseen:
			enemy.look_at_y_axis_only(PathfindingManager.player_position)
		else:
			enemy.orient_character(PathfindingManager.player_position, delta)
	else:#Necesitamos que se pare
		enemy.enemy_navigation.stop()


func lose_track() -> void:
	state_machine.transition_to("EnemyIdle", {})


func attack() -> void:
	print(enemy.name)
	state_machine.transition_to("EnemyAttack", {})


func can_chase() -> bool:
	if not chase_when_unseen:
		return true
	if not enemy.enemy_detection.does_player_sees():
		return true
	return false


func exit() -> void:
	enemy.enemy_audio.stop_footsteps()
	enemy.enemy_detection.lose_player_track.disconnect(lose_track)
	enemy.enemy_detection.player_entered_attack_range.disconnect(attack)
