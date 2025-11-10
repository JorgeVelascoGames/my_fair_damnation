extends PlayerComponent
class_name PlayerEvents

## This class manages the events in relation with the player

@export var sleep_to_dawn : Event
@export var rest_to_midnight : Event


func _ready() -> void:
	EventManager.new_event_pushed.connect(_on_event_pushed)
	EventManager.event_finished.connect(_on_event_finished)


func on_event_pushed(event : Event) -> void:
	pass

#region Propagate the signal on all the PlayerComponents of the player


func _on_event_pushed(event : Event) -> void:
	for node in player.get_children():
		if node is PlayerComponent:
			node.on_event_pushed(event)


func _on_event_finished(event: Event) -> void:
	for node in player.get_children():
		if node is PlayerComponent:
			node.on_event_finished(event)


#endregion
