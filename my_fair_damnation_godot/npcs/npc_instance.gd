extends Node3D
class_name NpcInstance

enum npc_instance_type{
	CONVERSATION,
	READING_MESSAGE
}

@export var instance_id : int
@export var npc_type := CONVERSATION
## The position the player will look at on conversations
@export var look_at_position : Node3D
## Optional: This will make the npc look towards the player
@export var look_at_modifier : LookAtModifier3D
@export var need_meds := true
@export var materials_to_dislove : Array[Material] = []
@export var override_material_surface := 0
@export var conversation_animation : String
@export var animation_player : AnimationPlayer
## The message to display
@export_multiline var message : String
@onready var player : Player = await PathfindingManager.get_player()
@onready var npc_conversation: NpcConversation = $NpcConversation
@onready var interactable: Interactable = $Interactable
@onready var model_container: Node3D = $ModelContainer
@onready var instance_animator_controller: NpcInstanceAnimator = $InstanceAnimatorController
@onready var npc_static_body_3d: StaticBody3D = $NpcStaticBody3D
@onready var npc_instance_audio_controller: NpcInstanceAudioController = $NpcInstanceAudioController

const CONVERSATION := npc_instance_type.CONVERSATION
const READING_MESSAGE := npc_instance_type.READING_MESSAGE

var npc : Npc
var is_sleeping := false


func _activate_instance() -> void:
	if model_container:
		model_container.show()
	interactable.process_mode = Node.PROCESS_MODE_INHERIT
	npc_conversation.process_mode = Node.PROCESS_MODE_INHERIT
	instance_animator_controller.select_animation()
	npc_static_body_3d.get_node("CollisionShape3D").disabled = false 
	npc_instance_audio_controller._on_instance_activated()
	print("%s activates instance: %s" %[npc.id.npc_name, instance_id])


func disable_instance() -> void:
	if model_container:
		model_container.hide()
	if interactable:
		interactable.process_mode = Node.PROCESS_MODE_DISABLED
	if npc_conversation:
		npc_conversation.process_mode = Node.PROCESS_MODE_DISABLED
	npc_static_body_3d.get_node("CollisionShape3D").disabled = true
	npc_instance_audio_controller._on_instance_disabled()


func start_looking_at_player() -> void:
	if look_at_modifier:
		look_at_modifier.target_node = player.camera_pivot.get_path()


func stop_looking_at_player() -> void:
	if look_at_modifier:
		look_at_modifier.target_node = ""


func disolve_mesh(duration := 2.0) -> void:
	if materials_to_dislove.is_empty():
		return

	for material in materials_to_dislove:
		if not material.has_parameter("dissolveSlider"):
			push_warning("Material does not have 'dissolveSlider' parameter.")
			return
		material.set("shader_parameter/dissolveSlider", 0.0)

		var tween := create_tween()
		tween.tween_method(
			func(value): material.set("shader_parameter/dissolveSlider", value),
			0.0, 1.0, duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(duration).timeout


func _on_interactable_interacted() -> void:
	match npc_type:
		CONVERSATION:
			if conversation_animation != "":
				animation_player.play(conversation_animation)
			player.start_conversation(npc_conversation, look_at_position)
		READING_MESSAGE:
			player.player_state_machine.transition_to("PlayerMessage", { "message" : message})
