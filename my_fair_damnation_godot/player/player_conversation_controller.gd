extends PlayerComponent
class_name PlayerConversationController


const DIALOG_BUTTON = preload("res://player/player_ui/dialog_button.tscn")

@onready var dialog_options: VBoxContainer = $"../PlayerUI/ConversationUI/DialogOptionsScroll/DialogOptions"
@onready var dialog_options_scroll: ScrollContainer = $"../PlayerUI/ConversationUI/DialogOptionsScroll"

var npc_conversation : NpcConversation
## To keep track in case of nested conversations
var current_conversation : Conversation
## Current dialog in display
var current_dialog : Dialog
## Used to gradually display the text
var text_display_tween : Tween
## If the text display animation is done
var text_fully_display := false
## The current dialog string array
var dialog_text : Array[String] = []
## The dialogs in this array will show no more
var consumed_dialogs : Array[Dialog] = [] # SAVE
## Dialogs are only aviable once per day
var once_per_day_dialogs : Array[Dialog] = [] # SAVE
##This is use to keep track of nested conversations
var nested_conversations : Array[Conversation] = []
## Keeps track of shown dialogs
var seen_dialogs : Array[Dialog] = [] # SAVE
##If the conversation options are being showed
var on_conversation_options := false


func _process(delta: float) -> void:
	if player.player_state_machine.state.name != "PlayerConversation":
		return


## Called at the beggining when interacting with the npc
func start_conversation(conversation : NpcConversation) -> void:
	current_dialog = null
	npc_conversation = conversation
	current_conversation = npc_conversation.conversation
	nested_conversations.clear()
	nested_conversations.append(conversation.conversation)
	%PlayerUI.conversation_ui.show()
	if npc_conversation.npc_instance: # To make sure that the conversation works on [EnvironmentConversation]
		npc_conversation.npc_instance.npc_instance_audio_controller._on_start_conversation()
		if npc_conversation.override_wellcome_dialog != null and can_show_dialog(npc_conversation.override_wellcome_dialog):
			open_dialog(npc_conversation.override_wellcome_dialog)
			return
	
		match npc_conversation.npc_instance.npc.npc_reputation.get_reputation_towards_player():
			ReputationManager.HOSTILE:
				if not conversation.hostile_wellcome_dialog:
					show_conversation()
					return
				open_dialog(conversation.hostile_wellcome_dialog)
			ReputationManager.NEUTRAL:
				if not conversation.neutral_wellcome_dialog:
					show_conversation()
					return
				open_dialog(conversation.neutral_wellcome_dialog)
			ReputationManager.POSITIVE:
				if not conversation.positive_wellcome_dialog:
					show_conversation()
					return
				open_dialog(conversation.positive_wellcome_dialog)
	else:
		if not conversation.neutral_wellcome_dialog:
			show_conversation()
			return
		open_dialog(conversation.neutral_wellcome_dialog)


## Shows the conversation buttons
func show_conversation() -> void:
	player.player_ui.npc_text_display.text = ""
	on_conversation_options = true
	player.player_ui.hide_interactable_hint()
	for button in dialog_options.get_children():
		button.queue_free()
	for dialog in current_conversation.dialog_options:
		if can_show_dialog(dialog):
			var button : DialogButton = DIALOG_BUTTON.instantiate() as DialogButton
			button.set_up_conversation_button(self, dialog)
			dialog_options.add_child(button)
	
	player.player_ui.npc_text_display.hide()
	dialog_options_scroll.show()
	
	# In case there is no buttons
	if dialog_options.get_children().is_empty():
		finish_conversation()


## This starts proccesing a new dialog option
func open_dialog(dialog : Dialog) -> void:
	current_dialog = dialog
	seen_dialogs.append(dialog)
	dialog_text.clear()
	if dialog.randomize_dialog:
		dialog_text.append(dialog.dialog_text.pick_random())
	else:
		dialog_text = dialog.dialog_text.duplicate()
	
	player.player_ui.npc_text_display.show()
	dialog_options_scroll.hide()
	next_dialog_text()


## Called to show the next entry in the dialog array
func next_dialog_text() -> void:
	if dialog_text.is_empty():
		finished_dialog()
		return
	show_dialog_text(tr(dialog_text.pop_front()))


## Will display the given text in the dialog label
func show_dialog_text(text : String) -> void:
	player.player_ui.npc_text_display.show()
	print("SHOW DIALOGO TEXT")
	text_fully_display = false
	on_conversation_options = false
	player.player_ui.hide_interactable_hint()
	if npc_conversation.npc_instance:
		npc_conversation.npc_instance.npc_instance_audio_controller.talk()
	
	var full_text := text
	player.player_ui.npc_text_display.text = ""
	
	for i in full_text.length():
		player.player_ui.npc_text_display.text += full_text[i]
		await get_tree().create_timer(1.0 / current_dialog.characters_per_second).timeout
	
	player.player_ui.show_interactable_hint("MENU_02")
	text_fully_display = true


func finished_dialog() -> void:
	print("FINISHED DIALOG")
	apply_dialog_reputation()
	
	player.madness.add_madness(current_dialog.madness_cost)
	
	for event in current_dialog.events_to_push:
		EventManager.push_new_event(event)
	
	for event in current_dialog.events_to_finish:
		EventManager.finish_event(event)
	
	if current_dialog.take_unlock_item:
		player.player_inventory.try_take_item(current_dialog.items_to_unclok_dialog[0])
	
	if current_dialog.gained_item != null:
		player.player_inventory.give_item(current_dialog.gained_item)
	
	if current_dialog.one_time_dialog: #Importante hacerlo al final del diálogo, por si se cierra el juego a la mitad
		consumed_dialogs.append(current_dialog)
	
	if current_dialog.once_per_day_dialog:
		once_per_day_dialogs.append(current_dialog)
	
	if current_dialog.finish_conversation:
		finish_conversation()
		return
	
	current_conversation = select_new_conversation_after_dialog()
	
	show_conversation()


func select_new_conversation_after_dialog() -> Conversation:
	var conversation : Conversation = current_conversation
	if current_dialog.response_conversation != null:
		nested_conversations.append(current_conversation) #Its done before assigning the new conversation because of the pop_back in the next elif statement
		conversation = current_dialog.response_conversation
	elif current_dialog.go_back_nested_conversation and not nested_conversations.is_empty():
		conversation = nested_conversations.pop_back()
	return conversation


func apply_dialog_reputation() -> void:
	if not npc_conversation.npc_instance:
		return
	npc_conversation.npc_instance.npc.npc_reputation.reputation_with_player += current_dialog.reputation_with_player_changed
	for key in current_dialog.npc_reputation_change:
		npc_conversation.npc_instance.npc.npc_reputation.reputation_with_other_npcs[key] += current_dialog.npc_reputation_change[key]


## Called when the "continue" key is 
func _on_next_dialog_key_pressed() -> void:
	if on_conversation_options:
		return
	if not text_fully_display: # En un principio, no se puede saltar la animación... ya veremos si cambia
		#text_display_tween.kill()
		#text_display_tween = null
		#npc_text_display.visible_ratio = 1.0
		#text_fully_display = true
		print("NO SE HA MOSTRADO TODO DIALOGO")
		return
	next_dialog_text()


## Determines if a dialog can be shown based on a serie of requirements
func can_show_dialog(dialog : Dialog) -> bool:
	# Check the save system
	if dialog.dialog_id in SaveDataServer.get_saved_data().consumed_dialogs:
		consumed_dialogs.append(dialog)
	if dialog.dialog_id in SaveDataServer.get_saved_data().seen_dialogs:
		seen_dialogs.append(dialog)
	if dialog.dialog_id in SaveDataServer.get_saved_data().once_per_day_dialogs:
		once_per_day_dialogs.append(dialog)
	
	# Check day
	if DayNightCycleController.day_count < dialog.min_day_to_see_dialog:
		return false
	
	# Required dialogs
	if not dialog.dialogs_to_unlock.is_empty():
		for d in dialog.dialogs_to_unlock:
			if not seen_dialogs.has(d):
				print("%s can't be shown: Another dialog(s) must be seen first" % [dialog.dialog_id])
				return false
	
	# Consumed
	if dialog.one_time_dialog and consumed_dialogs.has(dialog):
		print("%s can't be shown: This dialog can only been seen once" % [dialog.dialog_id])
		return false
	# Once per day
	if dialog.once_per_day_dialog and once_per_day_dialogs.has(dialog):
		print("%s can't be shown: This dialog can only been seen once per day" % [dialog.dialog_id])
		return false
	# Events related
	if dialog.current_event_to_trigger_conversation != null and not EventManager.current_events.has(dialog.current_event_to_trigger_conversation):
		print("%s can't be shown: Some events needs to be happening to show this dialog" % [dialog.dialog_id])
		return false
	for event in dialog.current_events_to_trigger_conversation:
		if not EventManager.current_events.has(event):
			print("%s can't be shown: Some events needs to be happening to show this dialog" % [dialog.dialog_id])
			return false
	if dialog.pased_events_to_trigger_conversation != null and not EventManager.passed_events.has(dialog.pased_events_to_trigger_conversation):
		print("%s can't be shown: Some events needs to be finished to show this dialog" % [dialog.dialog_id])
		return false
	for event in dialog.current_event_to_block_conversation:
		if event in EventManager.current_events:
			print("%s can't be shown: Some events are happening" % [dialog.dialog_id])
			return false
	for event in dialog.pased_event_to_block_conversation:
		if event in EventManager.passed_events:
			print("%s can't be shown: Some events already happened" % [dialog.dialog_id])
			return false
	
	#Reputation related
	if not dialog.reputation_level_to_unlock.is_empty():
		var is_level_in_array := false
		for level in dialog.reputation_level_to_unlock:
			if level == npc_conversation.npc_instance.npc.npc_reputation.get_reputation_towards_player():
				is_level_in_array = true
		if not is_level_in_array:
			print("%s can't be shown: The reputation level must be different" % [dialog.dialog_id])
			return false
	
	# Items related
	for item in dialog.items_to_unclok_dialog:
		if not player.player_inventory.items.has(item):
			print("%s can't be shown: %s must be on the inventory" % [dialog.dialog_id, item.item_name])
			return false
	for item in dialog.items_lock_dialog:
		if item in player.player_inventory.items:
			print("%s can't be shown: %s must NOT be on the inventory" % [dialog.dialog_id, item.item_name])
			return false
	print("%s dialog can be shown"%[dialog.dialog_id])
	return true


func finish_conversation() -> void:
	#player.player_state_machine.transition_to(current_dialog.player_state_post_conversation, {})
	player.player_state_machine.state.on_exit_conversation(current_dialog.player_state_post_conversation)


func on_day_start() -> void:
	once_per_day_dialogs.clear()
	SaveDataServer.clean_once_per_day_dialogs()


func save_dialogs() -> void:
	SaveDataServer.save_dialogs(consumed_dialogs, once_per_day_dialogs, seen_dialogs)


func _load(data : SavedData) -> void:
	pass # En este caso todo se comprueba en el check [method can_show_dialog] porque
	# no tenemos un vault de dialogos, ya que están creados directamente en editor y no en carpeta
