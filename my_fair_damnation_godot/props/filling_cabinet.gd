extends Node3D
class_name FillingCabinet

@export var cabinet_id : int
##Necessary to open it
@export var key_item : Item
@export var item_to_give : Item
@export var extra_items_to_give : Array[Item] = []
@export var event_to_push : Event
@export var only_at_night := false

@onready var interactable: Interactable = $Interactable
@onready var animation_player: AnimationPlayer = $FillingCabinetModel/AnimationPlayer

var player : Player
var opened := false

const EMPTY_QUOTES : Array[String] = [
	"empty_drawer_001",
	"empty_drawer_002",
	"empty_drawer_003",
	"empty_drawer_004"
]


func _ready() -> void:
	player = await PathfindingManager.get_player()
	animation_player.play("closed")


func _on_interactable_start_interacting() -> void:
	await get_tree().process_frame
	if only_at_night and DayNightCycleController.current_period != DayNightCycleController.NIGHT:
		player.player_state_machine.state.cancel_interaction()
		player.player_ui.display_gameplay_text(tr("cant_open_at_day"))
		return
	if key_item != null:
		if not player.player_inventory.items.has(key_item):
			if player.player_state_machine.state == PlayerInteracting:
				player.player_state_machine.state.cancel_interaction()
				player.player_ui.display_gameplay_text(tr("key_miss"))
				return
	animation_player.play("forcing")


func _on_interactable_interrupt_interacting() -> void:
	animation_player.play("closed", .3)


func _on_interactable_interacted() -> void:
	opened = true
	SaveDataServer.save_filling_cabinets(cabinet_id, opened)
	interactable.queue_free()
	animation_player.play("open", .3)
	if event_to_push:
		EventManager.push_new_event(event_to_push)
	if item_to_give == null and extra_items_to_give.is_empty():
		player.player_ui.display_gameplay_text(tr(EMPTY_QUOTES.pick_random()))
		return
	if item_to_give != null:
		player.player_inventory.give_item(item_to_give)
	for item in extra_items_to_give:
		player.player_inventory.give_item(item)


func _load(data : SavedData) -> void:
	if not data.filling_cabinets.keys().has(cabinet_id):
		return
	if data.filling_cabinets[cabinet_id]:
		opened = true
		animation_player.play("open")
		interactable.queue_free()
