extends NpcInstanceController
class_name NurseInstanceController

@export var first_day_instance : NpcInstance
@export var start_game_event : Event


func _ready() -> void:
	super()
	await get_tree().create_timer(1).timeout #Para que de tiempo a cargar los eventos para la siguiente linea
	if EventManager.current_events.has(start_game_event):
		return
	_activate_instance(first_day_instance)
