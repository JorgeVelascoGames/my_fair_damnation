extends Node3D
class_name SearchableContainer

## Represents a searchable container where the player can find items and trigger events.

## All items in this array will be given to the player upon interaction.
@export var items : Array[Item] = []

## All events in this array will be pushed to the EventManager upon interaction.
@export var events : Array[Event] = []

## These events will be marked as finished if they are present in the current_events list of the EventManager.
@export var events_to_pass : Array[Event] = []

## If true, only one random item from [member items] will be given to the player.
@export var randomize_item := false

## If true, only one random event from [member events] will be pushed to the EventManager.
@export var randomize_event := false

## If true, the container will be available again each new day.
@export var refill_at_dawn := false

## If true, the container will be available again each night.
@export var refill_at_nightfall := false

## The message the player will see if the container is empty.
@export var empty_message := "It's empty"

## If true, the container will be destroyed after being searched.
@export var destroy_after_search := false

## Optional item overrides based on whether specific events are active or have passed.
## If the given event is found in EventManager, the corresponding item will override the default ones.
@export var conditional_items : Dictionary = {} # { Event: Item }

## Reference to the player node.
@onready var player : Player = await PathfindingManager.get_player()

## Indicates whether the container has already been searched.
var searched := false


## Called when the node enters the scene tree.
func _ready() -> void:
	DayNightCycleController.day_started.connect(_on_day_started)
	DayNightCycleController.night_started.connect(_on_night_started)


## Called when the container is interacted with.
func _on_interactable_interacted() -> void:
	if searched:
		player.player_ui.display_gameplay_text(empty_message)
	else:
		_search_container()


## Performs the logic of giving items and triggering events.
func _search_container() -> void:
	var item_given := false

	# Check for conditional item overrides based on current or passed events
	for event in conditional_items.keys():
		if event in EventManager.current_events or event in EventManager.passed_events:
			player.player_inventory.give_item(conditional_items[event])
			item_given = true
			break

	# Fallback to default item logic
	if not item_given:
		if randomize_item and items.size() > 0:
			player.player_inventory.give_item(items.pick_random())
		else:
			for item in items:
				player.player_inventory.give_item(item)

	# Trigger events
	if randomize_event and events.size() > 0:
		EventManager.push_new_event(events.pick_random())
	else:
		for event in events:
			EventManager.push_new_event(event)

	# Mark events as finished
	for event in events_to_pass:
		EventManager.finish_event(event)

	searched = true

	if destroy_after_search:
		queue_free()


## Resets the container if refilling is enabled.
func _on_day_started() -> void:
	if refill_at_dawn:
		searched = false


func _on_night_started() -> void:
	searched = false
