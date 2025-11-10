extends Node3D
class_name EnvironmentConversation

@onready var npc_conversation: NpcConversation = $NpcConversation


func _on_interactable_interacted() -> void:
	npc_conversation.show_conversation()
