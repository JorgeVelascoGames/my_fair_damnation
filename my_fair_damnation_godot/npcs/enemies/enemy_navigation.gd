extends NavigationAgent3D
class_name EnemyNavigation

##This script controls the movement of the player and its navigation on a navmesh

@onready var enemy : Enemy = $".."

var speed := 1.0
var target := Vector3.ZERO
var is_moving := false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var momentum_multiplier := 2.0
@export var fall_multiplier : = 2


func move_to(pos : Vector3, _speed := 1.0) -> void:
	target = pos
	speed = _speed
	is_moving = true


func stop() -> void:
	is_moving = false
	target = Vector3.ZERO
	enemy.velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if not is_moving:
		enemy.velocity = Vector3.ZERO
		process_gravity(delta)
		enemy.move_and_slide()
		return
	var velocity_target := Vector3.ZERO
	target_position = target
	if not is_target_reached():
		velocity_target = get_local_navigation_direction() * speed
		enemy.orient_character(get_next_path_position(), delta)
		velocity = velocity.move_toward(velocity_target, delta * momentum_multiplier) 
	process_gravity(delta)
	enemy.apply_floor_snap()
	enemy.move_and_slide()


func get_local_navigation_direction() -> Vector3:
	var destination = get_next_path_position()
	var local_destination = destination - enemy.global_position
	return local_destination.normalized()


func process_gravity(delta):
	if not enemy.is_on_floor():
		if velocity.y >=0:
			enemy.velocity.y -= gravity
		else:
			enemy.velocity.y -= gravity * fall_multiplier


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	enemy.velocity = safe_velocity
