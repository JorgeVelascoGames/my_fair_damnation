extends NpcComponent
class_name NpcEvents

## Connects the npc to the EventManager. This is meant to be override for each
## npc use case


func _ready() -> void:
	EventManager.new_event_pushed.connect(_on_event_pushed)
	EventManager.event_finished.connect(_on_event_finished)


func _on_event_pushed(event : Event) -> void:
	npc.on_event_pushed(event)
	for node in npc.get_children():
		if node is NpcComponent:
			node.on_event_pushed(event)


func _on_event_finished(event: Event) -> void:
	npc.on_event_finished(event)
	for node in npc.get_children():
		if node is NpcComponent:
			node.on_event_finished(event)
