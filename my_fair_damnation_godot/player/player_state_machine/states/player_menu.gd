extends PlayerState
class_name PlayerMenu


func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO
	player.player_ui.options.close_options_menu.connect(close_menu)
	player.player_ui.options.open_options()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_menu() -> void:
	state_machine.transition_to("PlayerIdle", {})
	player.player_ui.options.close_options()


func physics_update(delta: float) -> void:
	player.move_and_slide() # To process gravity


func exit() -> void:
	player.player_ui.options.close_options_menu.disconnect(close_menu)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
