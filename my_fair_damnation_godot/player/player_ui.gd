extends CanvasLayer
class_name PlayerUI

# Mechanics
@onready var madness_bar: ProgressBar = %MadnessBar

#Interactable 
@onready var interactable_hint: HBoxContainer = $ControlHints/HintContainer/HBoxContainer/InteractableHint
@onready var interactable_key: Label = $ControlHints/HintContainer/HBoxContainer/InteractableHint/TextureRect/InteractableKey
@onready var interactable_description: Label = $ControlHints/HintContainer/HBoxContainer/InteractableHint/InteractableDescription

# Conversations
@onready var conversation_ui: MarginContainer = $ConversationUI
@onready var dialog_options_scroll: ScrollContainer = $ConversationUI/DialogOptionsScroll
@onready var npc_text_display: Label = %NpcTextDisplay

# Inventory
@onready var inventory_ui: InventoryUI = $InventoryUI

# Player info
@onready var player_gameplay_info_label: Label = %PlayerGameplayInfoLabel
@onready var player_gameplay_info_timer: Timer = $PlayerGameplayInfo/PlayerGameplayInfoTimer

# Message
@onready var message_ui: MarginContainer = $MessageUI
@onready var message_label: Label = $MessageUI/PanelContainer/MarginContainer/MessageLabel
@onready var continue_button: Button = $MessageUI/PanelContainer/MarginContainer/ContinueButton

# Miscelanea
@onready var player_black_screen: ColorRect = $PlayerBlackScreen

# Options menu
@onready var options: OptionMenu = $Options

var tween : Tween
var fade_tween : Tween


func _ready() -> void:
	interactable_hint.hide()


func show_interactable_hint(description : String, key := "E") -> void:
	interactable_key.text = key
	interactable_description.text = description
	interactable_hint.show()


func hide_interactable_hint() -> void:
	interactable_hint.hide()


func open_inventory() -> void:
	inventory_ui.display_inventory()
	$InventoryUI/Inventory.show()


func close_inventory() -> void:
	$InventoryUI/Inventory.hide()


func display_gameplay_text(text : String, time := 5.0, low_priority_text  := false, clean_text := false) -> void:
	if low_priority_text and player_gameplay_info_label.text != "":
		return
	#if !timer.is_stopped():
	player_gameplay_info_timer.stop()
	
	if tween != null:
		tween.stop()
		tween.kill() #In case multiple messages come at the same time
		player_gameplay_info_label.modulate.a = 1
	if clean_text:
		player_gameplay_info_label.text = ""
	
	player_gameplay_info_label.modulate.a = 1
	player_gameplay_info_label.text += "\n" + text
	player_gameplay_info_timer.start(time)


## Makes the black screen visible and fades it out over the given duration
func fade_in_black_screen(duration: float = 3.0) -> void:
	if fade_tween and fade_tween.is_running():
		return
	player_black_screen.show()
	player_black_screen.modulate.a = 1.0  # Start fully black
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(player_black_screen, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_tween.finished
	player_black_screen.hide()


func _on_player_gameplay_info_timer_timeout() -> void:
	tween = get_tree().create_tween()
	tween.tween_property(player_gameplay_info_label, "modulate:a", 0.0, 2.0)
	await tween.finished
	tween = null
	player_gameplay_info_label.text = ""
