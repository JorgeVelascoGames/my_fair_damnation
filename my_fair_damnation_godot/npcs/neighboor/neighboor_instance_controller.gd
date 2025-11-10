extends NpcInstanceController
class_name NeighboorInstanceController

@export var chapel_instance : NpcInstance
@export var condemnted_instance : NpcInstance
@export var final_instance : NpcInstance

@export var sorry_to_untie : Event
@export var paternity_test_given : Event
@export var goes_after_frank_unprepared : Event
@export var goes_after_frank_ready : Event
@export var confronted_about_photos : Event


## Triggers once daytime starts. This should be override
func manage_instances_on_day() -> void:
	super()
	if EventManager.current_events.has(goes_after_frank_ready):
		_activate_instance(final_instance)
		return
	if EventManager.current_events.has(goes_after_frank_unprepared):
		_activate_instance(condemnted_instance)
		return
	if EventManager.current_events.has(sorry_to_untie) and EventManager.current_events.has(paternity_test_given) and EventManager.current_events.has(confronted_about_photos):
		_activate_instance(chapel_instance)
