extends PlayerState
class_name PlayerTalking

##This state manages the conversation system. The _msg dicctionary on [method enter]
##must be filled with the npc's head position as "position", and the [Conversation] as "conversation"

#@export var min_time_between_messages := 1.0
#
#@onready var conversation_system: ConversationSystem = %ConversationSystem
#@onready var conversation_cd: Timer = $ConversationCD
#
#var target_look_at
#
#
#func enter(_msg : ={}) -> void:
	#player.velocity = Vector3.ZERO
	#target_look_at = _msg["position"]
	#conversation_system.start_conversation(_msg["conversation"])
#
#
#func update(delta) -> void:
	#player.camera_pivot.look_at(target_look_at)
	#var body_position = target_look_at
	#body_position.y = player.global_position.y
	#player.look_at(body_position)
#
#
#func _handle_input(event : InputEvent) -> void:
	#if event.is_action_pressed("interact") and conversation_cd.is_stopped():
		#conversation_cd.start(min_time_between_messages)
		#if not conversation_system.next_message():
			#state_machine.transition_to("Idle", {})
#
#
#func exit() -> void:
	#player.rotation.x = 0
	#player.rotation.z = 0
	#player.camera_pivot.rotation.y = 0
	#player.camera_pivot.rotation.z = 0
