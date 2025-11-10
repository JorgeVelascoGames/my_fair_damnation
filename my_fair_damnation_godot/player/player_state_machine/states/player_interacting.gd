extends PlayerState
class_name PlayerInteracting

##This state manages the interacting system. This is use to perform long interaction like
##opening a box

##Used to messure the interaction timer
@onready var interaction_timer: Timer = $InteractionTimer

##To force the player to look to the interacting item
var target_look_at


func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO
	target_look_at = _msg["position"]
	interaction_timer.start(_msg["duration"])


func update(delta) -> void:
	player.camera_pivot.look_at(target_look_at)
	var body_position = target_look_at
	body_position.y = player.global_position.y
	player.look_at(body_position)


func _handle_input(event : InputEvent) -> void:
	if event.is_action_released("interact"):
		cancel_interaction()


func cancel_interaction() -> void:
	state_machine.transition_to("PlayerIdle", {})
	player.player_interaction_manager.cancel_interaction()


func exit() -> void:
	player.rotation.x = 0
	player.rotation.z = 0
	player.camera_pivot.rotation.y = 0
	player.camera_pivot.rotation.z = 0
	
	interaction_timer.stop()


func _on_interaction_timer_timeout() -> void:
	player.player_interaction_manager.interact()
	state_machine.transition_to("PlayerIdle", {})
