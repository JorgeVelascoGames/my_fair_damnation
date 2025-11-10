extends Node
class_name NpcConversation

## This node holds a conversation for a particular instance of an npc

signal end_conversation

@export var npc_instance: NpcInstance
@export var conversation : Conversation
## The wellcome dialog shown before the first conversation
@export var neutral_wellcome_dialog : Dialog
## The wellcome dialog shown before the first conversation if the npc hates the player
@export var hostile_wellcome_dialog : Dialog
## The wellcome dialog shown before the first conversation if the npc likes the player
@export var positive_wellcome_dialog : Dialog
## This dialog will have priority over the rest. Mark it as one day only or one time only
## So the first time the player talks to this character, this dialog will show up
@export var override_wellcome_dialog: Dialog


## Called to show the conversation to the player
func show_conversation() -> void:
	var player = await PathfindingManager.get_player()
	player.start_conversation(self)
