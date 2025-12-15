extends PlayerState

class_name PlayerWalk

const FLASHLIGHT = preload("uid://e7kghipeqb6p")
const GUN = preload("uid://disj0tsesscyo")

@export var walking_speed := 1.2


func enter(_msg: = { }) -> void:
	player.player_audio.start_footsteps()


func update(delta):
	if player.direction(delta) == Vector3.ZERO:
		state_machine.transition_to("PlayerIdle", { })

	if !player.is_on_floor():
		state_machine.transition_to("Jump", { })

	if Input.is_action_pressed("sprint"):
		state_machine.transition_to("PlayerRun", { })

	var col = player.player_interaction_manager.try_get_interactable()
	if col is Interactable:
		player.player_ui.show_interactable_hint(col.interactable_hint)
	else:
		player.player_ui.hide_interactable_hint()


func physics_update(delta: float) -> void:
	handle_camera_rotation(delta)
	var direction = player.direction(delta)
	if direction:
		player.velocity.x = direction.x * walking_speed
		player.velocity.z = direction.z * walking_speed
		#print(player.velocity.z)
	player.move_and_slide()


func handle_camera_rotation(_delta: float) -> void:
	player.rotate_y(player.mouse_motion.x * AppManager.camera_sensibility)
	player.camera_pivot.rotate_x(player.mouse_motion.y * AppManager.camera_sensibility)
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
	player.player_audio.stop_footsteps()
	SaveDataServer.save_game()
	player.player_ui.hide_interactable_hint()
