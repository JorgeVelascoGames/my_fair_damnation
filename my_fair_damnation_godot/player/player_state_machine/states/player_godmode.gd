extends PlayerState
class_name PlayerGodmode


@onready var console: Console = $"../../PlayerUI/Console"

var remove_madness_code := "remove_madness_"
var add_maddnes_code := "add_madness_"


func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	console.open_console()


func physics_update(delta: float) -> void:
	player.move_and_slide() # To process gravity
	if Input.is_action_just_pressed("ui_cancel"):
		state_machine.transition_to("PlayerIdle", {})




func exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	console.close_console()
