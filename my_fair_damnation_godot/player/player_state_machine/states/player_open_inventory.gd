extends PlayerState
class_name PlayerOpenInventory

@onready var camera_pivot: Node3D = %CameraPivot

var tween : Tween
var opened := false


func enter(_msg : ={}) -> void:
	SaveDataServer.save_game()
	player.velocity = Vector3.ZERO
	tween = create_tween()
	var target_rotation = Vector3(-60, 0, 0) * deg_to_rad(1)
	tween.tween_property(camera_pivot, "rotation", target_rotation, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished
	player.player_audio.open_inventory()
	%PlayerUI.open_inventory()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	opened = true


func _handle_input(event : InputEvent) -> void:
	if not opened:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_focus_next"):
		state_machine.transition_to("PlayerIdle", {})


func exit() -> void:
	if tween:
		tween.kill()
	%PlayerUI.close_inventory()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	opened = false
	player.player_audio.close_inventory()
