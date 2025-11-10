extends Node3D
class_name EnemySpawner

##This node will spawn the given scene. The spawn happens on event pushed or finished,
##and it can be delayed

##The scene to spawn
@export var enemy_to_spawn : Enemy
##Optional node to be parent for the new spawned node
@export var enemy_parent : Node3D
##The spawn will be triggered when any event from this array is pushed or finished
@export var spawn_triggering_events : Array[Event] = []
@export var despawn_triggering_events : Array[Event] = []
##The spawn will be delayed by this time
@export var delay_time := 0.0

var original_position : Vector3


func _ready() -> void:
	EventManager.event_finished.connect(check_event)
	EventManager.new_event_pushed.connect(check_event)
	original_position = enemy_to_spawn.position
	despawn()


func check_event(event : Event) -> void:
	if spawn_triggering_events.has(event):
		spawn()
	if despawn_triggering_events.has(event):
		despawn()


func spawn() -> void:
	if delay_time > 0:
		await get_tree().create_timer(delay_time).timeout
	
	enemy_to_spawn.position = original_position
	enemy_to_spawn._activate_instance()


func despawn() -> void:
	enemy_to_spawn.disable_instance()
