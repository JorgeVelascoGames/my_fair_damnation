extends NpcComponent
class_name NurseConversationController

## This class manages the particular use cases for the nurse

## This dialog is shown the first time the player talks to the nurse
@export var first_time_dialog : Dialog
## This is the regular normal dialog for the neutral reputation category
@export var normal_neutral_dialog : Dialog
## This events means that the player talked for the nurse at least once
@export var player_nurse_meet_event : Event

## The [NpcConversation] from the main npc instance
@onready var main_npc_conversation: NpcConversation = $"../NpcInstanceController/MainInstance/NpcConversation"


#func on_event_pushed(event : Event) -> void:
	#if event.event_name == player_nurse_meet_event.event_name:
		#main_npc_conversation.neutral_wellcome_dialog = normal_neutral_dialog
