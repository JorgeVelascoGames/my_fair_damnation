extends NpcComponent
class_name NurseReputationController

## The light container, to gather them later in an array
@export var light_container : Node3D
## The amount of reputation the player will lose if the lights
## are not turned off before going to sleep. It's passed as abs, so
## a negative value will be used still as a lost
@export var light_neglect_reputation_loss := 10
## This event is passed when light task is failed, so the correct dialog
## will show up
@export var light_neglect_event : Event

var lights : Array[InteractableLight] = []


func _ready() -> void:
	for light in light_container.get_children():
		if light is InteractableLight:
			lights.append(light)


func on_day_start() -> void:
	# First, we finish the previous event
	EventManager.finish_event(light_neglect_event)
	
	var is_happy := true
	
	for light in lights:
		if light.light_on:
			is_happy = false
	
	if not is_happy:
		EventManager.push_new_event(light_neglect_event)
		npc.npc_reputation.reputation_change(abs(light_neglect_reputation_loss))
