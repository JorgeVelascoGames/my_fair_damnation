extends PlayerState

class_name PlayerMenu

var opened := false


func enter(_msg: = { }) -> void:
	player.velocity = Vector3.ZERO
	player.player_ui.options.close_options_menu.connect(close_menu)
	player.player_ui.options.open_options()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	opened = true


func _handle_input(event: InputEvent) -> void:
	if not opened:
		return
	if event.is_action_pressed("ui_cancel"):
		state_machine.transition_to("PlayerIdle", { })


func close_menu() -> void:
	state_machine.transition_to("PlayerIdle", { })


func physics_update(_delta: float) -> void:
	player.move_and_slide() # To process gravity


func exit() -> void:
	player.player_ui.options.close_options()
	player.player_ui.options.close_options_menu.disconnect(close_menu)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	opened = false
