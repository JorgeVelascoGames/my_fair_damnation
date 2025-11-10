extends PlayerState
class_name PlayerMessage

signal continue_button_pressed


func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO
	player.player_ui.message_ui.show()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	player.player_ui.continue_button.pressed.connect(on_continue_button_press)
	player.player_ui.message_label.text = _msg["message"]


func physics_update(delta: float) -> void:
	player.move_and_slide() # To process gravity


func on_continue_button_press() -> void:
	state_machine.transition_to("PlayerIdle", {})
	continue_button_pressed.emit()


func exit() -> void:
	player.player_ui.continue_button.pressed.disconnect(on_continue_button_press)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.player_ui.message_ui.hide()
