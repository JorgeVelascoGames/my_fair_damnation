extends Node3D
class_name Spawner

## Spawner nodes are used to instantiate and manage objects (NPCs, items, obstacles, etc.) 
## under specific conditions such as time of day, interaction, or triggered events.

## The scene that will be instantiated by this spawner.
@export var scene_to_spawn : PackedScene

@export_category("Spawn Options")

## Optional marker that sets the spawn position. If null, spawns at the spawner's position.
@export var spawn_position_marker : Marker3D

## Optional parent node for the spawned instance. If null, this spawner will be used as parent.
@export var spawn_parent_node : Node3D

## If false, prevents spawning if another instance already exists.
@export var allow_multiple_spawns := false

## Whether the node should spawn at the beginning of the day.
@export var spawn_during_day := false

## Whether the node should spawn at the beginning of the night.
@export var spawn_during_night := false

## Spawns when this specific event starts.
@export var spawn_on_event_start : Event

## Spawns when this specific event ends.
@export var spawn_on_event_end : Event

## Spawns when this specific interactable is interacted with.
@export var spawn_on_interaction : Interactable

@export_category("Clear Options")

## Deletes the spawned instance at the beginning of the day.
@export var clear_during_day := false

## Deletes the spawned instance at the beginning of the night.
@export var clear_during_night := false

## Deletes the spawned instance when this event starts.
@export var clear_on_event_start : Event

## Deletes the spawned instance when this event ends.
@export var clear_on_event_end : Event

@export_category("Other Options")

## If true, the spawner deletes itself after spawning. Does nothing if parent is null.
@export var destroy_spawner_after_spawn := false

## Holds a reference to the current spawned node.
var spawned_instance : Node3D


func _ready() -> void:
	EventManager.new_event_pushed.connect(_on_event_started)
	EventManager.event_finished.connect(_on_event_ended)
	DayNightCycleController.day_started.connect(_on_day_started)
	DayNightCycleController.night_started.connect(_on_night_started)
	if spawn_on_interaction:
		spawn_on_interaction.interacted.connect(_on_interactable_triggered)


## Called when an event starts. Checks spawn and clear conditions.
func _on_event_started(event: Event) -> void:
	if event == spawn_on_event_start:
		spawn_node()
	if event == clear_on_event_start:
		delete_spawned_node()


## Called when an event ends. Checks spawn and clear conditions.
func _on_event_ended(event: Event) -> void:
	if event == spawn_on_event_end:
		spawn_node()
	if event == clear_on_event_end:
		delete_spawned_node()


## Called when the associated interactable is triggered.
func _on_interactable_triggered() -> void:
	spawn_node()


## Called when the day starts. Handles spawn and clear logic related to daytime.
func _on_day_started() -> void:
	if spawn_during_day:
		spawn_node()
	if clear_during_day:
		delete_spawned_node()


## Called when the night starts. Handles spawn and clear logic related to nighttime.
func _on_night_started() -> void:
	if spawn_during_night:
		spawn_node()
	if clear_during_night:
		delete_spawned_node()


## Instantiates and places the configured scene under the appropriate parent.
func spawn_node() -> void:
	if not scene_to_spawn:
		push_warning("Spawner tried to spawn without a scene assigned.")
		return

	if not allow_multiple_spawns and is_instance_valid(spawned_instance):
		return

	var instance = scene_to_spawn.instantiate() as Node3D
	if not instance:
		push_warning("Failed to instantiate node from scene.")
		return

	var parent = spawn_parent_node if spawn_parent_node else self
	parent.add_child(instance)

	var spawn_position = spawn_position_marker.global_transform.origin if spawn_position_marker else global_transform.origin
	instance.global_transform.origin = spawn_position

	spawned_instance = instance

	if destroy_spawner_after_spawn and spawn_parent_node:
		queue_free()


## Deletes the currently spawned instance, if any.
func delete_spawned_node() -> void:
	if is_instance_valid(spawned_instance):
		spawned_instance.queue_free()
		spawned_instance = null
