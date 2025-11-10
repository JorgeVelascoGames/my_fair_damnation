extends Node

@export var triggering_events : Array[Event] = []
@export var destructor_id : int = 0


func _ready() -> void:
	EventManager.new_event_pushed.connect(_on_event)


func _on_event(event : Event) -> void:
	if event in triggering_events:
		SaveDataServer.save_destructors(destructor_id)
		queue_free()


func _load(save : SavedData) -> void:
	if save.descturctors_ids.has(destructor_id):
		queue_free()
