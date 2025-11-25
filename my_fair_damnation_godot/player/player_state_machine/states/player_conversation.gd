extends PlayerState
class_name PlayerConversation

## This state manages the conversation system


@onready var player_conversation_controller: PlayerConversationController = $"../../PlayerConversationController"

##To force the player to look to the interacting item
var target_look_at : Node3D
var force_look_at := true
var npc_conversation : NpcConversation

func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO
	var pos = _msg["position"]
	if pos is Node3D:
		target_look_at = pos
		force_look_at = true
	else:
		force_look_at = false
	npc_conversation = _msg["conversation"]
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	player.player_conversation_controller.start_conversation(npc_conversation)
	if npc_conversation.npc_instance:
		npc_conversation.npc_instance.start_looking_at_player()


func update(delta) -> void:
	if not force_look_at:
		return
	player.camera_pivot.look_at(target_look_at.global_position)
	var body_position = target_look_at.global_position
	body_position.y = player.global_position.y
	player.look_at(body_position)


func _handle_input(event : InputEvent) -> void:
	if event.is_action_pressed("interact"):
		player_conversation_controller._on_next_dialog_key_pressed()


func on_exit_conversation(state_post_conversation : String) -> void:
	player_conversation_controller.dialog_options_scroll.hide()
	player.player_ui.npc_text_display.hide()
	player_conversation_controller.save_dialogs()
	npc_conversation.end_conversation.emit()
	if npc_conversation.npc_instance:
		npc_conversation.npc_instance.npc_instance_audio_controller._on_stop_conversation()
	await get_tree().create_timer(.1).timeout #To make sure we cant break the game by spaming a key
	state_machine.transition_to(state_post_conversation, {})


func exit() -> void:
	player.rotation.x = 0
	player.rotation.z = 0
	player.camera_pivot.rotation.y = 0
	player.camera_pivot.rotation.z = 0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if force_look_at:
		force_look_at = false
		npc_conversation.npc_instance.stop_looking_at_player()
