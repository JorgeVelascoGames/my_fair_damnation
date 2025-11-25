extends EnemyState
class_name EnemyWalk

@export var walk_speed := 1.5

@onready var enemy_navigation: EnemyNavigation = $"../../EnemyNavigation"

var target_position: Vector3


func _ready():
	await get_tree().create_timer(4).timeout
	target_position = enemy.global_position


func enter(_msg = {}) -> void:
	enemy.enemy_audio.start_footsteps()
	enemy_animator_controller.play_walk_animation()
	enemy.enemy_detection.found_player.connect(start_chasing)
	enemy_navigation.avoidance_mask = 1
	var my_name = owner.name
	if is_instance_valid(_msg["position"]):
		target_position = _msg["position"]
	enemy.enemy_navigation.move_to(target_position, walk_speed)
	enemy.enemy_navigation.target_reached.connect(position_reached)


func position_reached() -> void:
	state_machine.transition_to("EnemyIdle", {})


func physics_update(delta) -> void:
	enemy.move_and_slide()


func start_chasing() -> void:
	state_machine.transition_to("EnemyChasing", {})


func exit() -> void:
	enemy.enemy_audio.stop_footsteps()
	enemy.enemy_navigation.target_reached.disconnect(position_reached)
	enemy.enemy_detection.found_player.disconnect(start_chasing)
