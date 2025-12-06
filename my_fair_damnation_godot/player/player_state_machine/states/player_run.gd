extends PlayerState

class_name PlayerRun

const GUN = preload("uid://disj0tsesscyo")

@export var run_speed := 2.4

# Ajustes para el head-bop
## Velocidad del head-bop
@export var bob_frequency := 8.0
## Altura máxima del head-bop
@export var bob_amplitude := 0.015
@export var head: Node3D

@onready var original_camera_pos := head.position
@onready var player_stamina: PlayerStamina = $"../../PlayerStamina"

var bob_time: float = 0.0


func enter(_msg: = { }) -> void:
	bob_time = 0.0
	player_stamina.start_spending_stamina()
	player.player_audio.start_running()


func update(delta):
	if player.direction(delta) == Vector3.ZERO:
		state_machine.transition_to("Idle", { })

	if not Input.is_action_pressed("sprint"):
		state_machine.transition_to("PlayerWalk", { })

	if !player.is_on_floor():
		state_machine.transition_to("Jump", { })

	if Input.is_action_just_pressed("ui_focus_next"):
		state_machine.transition_to("PlayerOpenInventory", { })


func physics_update(delta: float) -> void:
	handle_camera_rotation(delta)
	var direction = player.direction(delta)
	if direction:
		player.velocity.x = direction.x * run_speed
		player.velocity.z = direction.z * run_speed

		# Head-bop
		# Incrementamos el contador y calculamos un desplazamiento sinusoidal
		if AppManager.use_head_bob:
			bob_time += delta
			var offset_y = sin(bob_time * bob_frequency) * bob_amplitude

			# Ajustamos la traslación de la cabeza respecto a su posición base
			var head_pos = head.position
			head_pos.y -= offset_y
			head.position = head_pos
	else:
		bob_time = 0.0
	player.move_and_slide()


func handle_camera_rotation(_delta: float) -> void:
	player.rotate_y(player.mouse_motion.x * player.camera_sensibility)
	player.camera_pivot.rotate_x(player.mouse_motion.y * player.camera_sensibility)
	player.camera_pivot.rotation_degrees.x = clampf(
		player.camera_pivot.rotation_degrees.x,
		-90.0,
		90,
	)
	player.mouse_motion = Vector2.ZERO


func _handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("turn_on_flashlight"):
		player.try_turn_flashlight_on()
	if event.is_action_pressed("interact"):
		player.player_interaction_manager.try_interact()
	if event.is_action_pressed("ui_focus_next"):
		state_machine.transition_to("PlayerOpenInventory", { })
	if event.is_action_pressed("aim") and player.player_inventory.items.has(GUN):
		state_machine.transition_to("PlayerPrepareGun", { })
	if event.is_action_pressed("ui_cancel"):
		state_machine.transition_to("PlayerMenu", { })


func exit() -> void:
	player_stamina.stop_spending_stamina()
	var tween := create_tween()
	tween.tween_property(head, "position", original_camera_pos, 0.3)
	player.player_audio.stop_footsteps()
