extends PlayerState
class_name PlayerAiming

@export var base_aiming_sensitivity := 0.1
@export var aiming_moving_speed := .4
@export var irregular_sensitivity := false
@export var cd_between_shots := .7

@onready var gun_model: Node3D = %GunModel
@onready var camera_pivot: Node3D = %CameraPivot
@onready var randomize_sensitivity_timer: Timer = $RandomizeSensitivityTimer
@onready var bullet_raycast_3d: RayCast3D = $"../../PlayerUI/ItemDisplayer/SubViewport/ItemCamera/GunHolder/GunModel/BulletRaycast3D"
@onready var player_inventory: PlayerInventory = $"../../PlayerInventory"
@onready var shot_cd_timer: Timer = $ShotCDTimer

const BULLET = preload("res://items/item_vault/bullet.tres")
const GUN_SHOT = preload("res://assets/audio/player/gun_shot.wav")
const GUN_FIRED_NO_BULLETS_1 = preload("res://assets/audio/player/gun_fire_no_bullets/gun fired no bullets 1.wav")

var randomize_sensitivity : float


func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO
	gun_model.show()
	randomize_sensitivity_timer.start()


func physics_update(delta: float) -> void:
	handle_camera_rotation(delta)
	var direction = player.direction(delta)
	if direction:
		player.velocity.x = direction.x * aiming_moving_speed
		player.velocity.z = direction.z * aiming_moving_speed
		#print(player.velocity.z)
	else:
		player.velocity = Vector3.ZERO
	player.move_and_slide()


func handle_camera_rotation(_delta:float) -> void:
	var correct_sensitivity = base_aiming_sensitivity
	if irregular_sensitivity:
		correct_sensitivity = randomize_sensitivity
	player.rotate_y(player.mouse_motion.x * correct_sensitivity)
	player.camera_pivot.rotate_x(player.mouse_motion.y * correct_sensitivity)
	player.camera_pivot.rotation_degrees.x = clampf(
		player.camera_pivot.rotation_degrees.x, -90.0, 90)
	player.mouse_motion = Vector2.ZERO


func _handle_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		try_shoot()
	if event.is_action_released("aim"):
		state_machine.transition_to("PlayerIdle", {})


func exit() -> void:
	gun_model.hide()
	randomize_sensitivity_timer.stop()


func _on_randomize_sensitivity_timer_timeout() -> void:
	randomize_sensitivity = base_aiming_sensitivity * randf_range(.8, 3.8)


func try_shoot() -> void:
	if shot_cd_timer.time_left > 0:
		return
	shot_cd_timer.start(cd_between_shots)
	if player_inventory.try_take_item(BULLET):
		shoot()
		player.player_audio.shoot()
	else:
		player.player_audio.try_shoot_no_bullets()

func shoot() -> void:
	weapon_recoil()
	player.player_audio.shoot()
	if not bullet_raycast_3d.is_colliding():
		return
	var col = bullet_raycast_3d.get_collider()
	print(col)
	if col is EnemyHitbox:
		player.player_audio.shoot_hit()
		col.damage()


func weapon_recoil() -> void:
	var jitter_strength = 0.33  # Radianes
	camera_pivot.rotate_x(jitter_strength)
	camera_pivot.rotation_degrees.x = clampf(
		player.camera_pivot.rotation_degrees.x, -90.0, 70.0)
