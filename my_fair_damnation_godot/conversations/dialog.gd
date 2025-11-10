extends Resource
class_name Dialog

##A brief explanation of this dialog for the inspector
@export_multiline var dialog_description : String
@export var characters_per_second := 50.0
## To identify this dialogs in other system such as the save system. Must be unique for
## each dialog
@export var dialog_id : String
## The option for the player that will trigger this dialog
@export var player_dialog_option : String
## The dialog text, displayed in order
@export var dialog_text : Array[String]
## If true, the entire dialog will be only one of the strings from [member dialog_text] instead
## of the hole array
@export var randomize_dialog := false
## If this is true, the conversation will end with this dialog
@export var finish_conversation := false
## The state for the player after conversation if [member finish_conversation] is true
@export var player_state_post_conversation := "PlayerIdle"
##Locura extra que se añadirá al jugador tras completar el diálogo. Puede ser
##Negativo o positivo
@export var madness_cost := 0.0

##If true, makes this dialog dissapear once selected
@export var one_time_dialog := true
##If true, this is only aviable once per day
@export var once_per_day_dialog := false
##The responding conversation after the dialog is finished. 
@export var response_conversation : Conversation
##If true, finishing this dialog will return to the previous nested conversation
@export var go_back_nested_conversation := false
##Dialogs in this array should be seen at least once for this dialog to be aviable
@export var dialogs_to_unlock : Array[Dialog] = []
##The dialog wont show up unless this amount of days have passed 
@export var min_day_to_see_dialog := -10

@export_group("Event related interactions")
##All the events on this array will be push to the event manager once this dialog ends
@export var events_to_push : Array[Event] = []
##If this is not null, this event must be on the current_events array on the EventManager for this dialog
##option to show up. [b]PLEASE DON'T FORGET THAT TRIGGER TYPE EVENT WON'T HAVE ANY EFFECT HERE, SINCE THEY ARE NOT ADDED TO ANY ARRAY[/b]
@export var current_event_to_trigger_conversation : Event
##The same as [member current_event_to_trigger_conversation], but suports multiple events. It's made latter in development, thats why 
##[member current_event_to_trigger_conversation] it's not deleted, because the game is constructed arround it
@export var current_events_to_trigger_conversation : Array[Event] = []
##If this is not null, this event must be on the passed event array on the EventManager for this dialog
##option to show up.[b]PLEASE DON'T FORGET THAT TRIGGER TYPE EVENT WON'T HAVE ANY EFFECT HERE, SINCE THEY ARE NOT ADDED TO ANY ARRAY[/b]
@export var pased_events_to_trigger_conversation : Event
##If any of the events on this array are on the event manager "current_conversation" array, this
##dialog will be blocked
@export var current_event_to_block_conversation : Array[Event]
##If any of the events on this array are on the event manager "pased_conversation" array, this
##dialog will be blocked
@export var pased_event_to_block_conversation : Array[Event]
##This dialog will finish any event on this array if its on the "current_events" array
@export var events_to_finish : Array[Event] = []

@export_group("Item related interactions")
##If not empty, this items will be needed to show this dialog option
@export var items_to_unclok_dialog : Array[Item] = []
##With this item in the [Inventory], the dialog won't show up
@export var items_lock_dialog : Array[Item] = []
##If true, the [member item_to_unlock_dialog] will get substracted from the player at the end
##of the dialog
@export var take_unlock_item := false
##If not null, the player will get this item at the end of the dialog
@export var gained_item : Item

@export_group("Reputation related interactions")
## The reputation level that unlock this dialog. If the player is not on some reputation level on this array, the dialog
## won't be aviable. If the array is empty, this is ignored
@export var reputation_level_to_unlock : Array[ReputationManager.reputation_level] = []
## The reputation change with the player at the end of the dialog
@export var reputation_with_player_changed := 0.0
## The target of the reputation change. If its null, it will affect the reputation with the player
@export var npc_reputation_change : Dictionary[NpcId, int] = {}
