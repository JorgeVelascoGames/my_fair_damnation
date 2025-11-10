extends Node

## Triggered when a new event happens
signal new_event_pushed(Event)
## Triggered when a current event is finished
signal event_finished(Event)

## Events than are happening are stored here 
@export var current_events : Array[Event] = []
## Events that ended on the [member current_events] array are stored here
@export var passed_events : Array[Event] = []
## Use this array to keep track of events added on current_events that should finish
## on a new day. So every new day, this array is cleared and all events on current_events
## that were here are passed to passed_events
var one_day_lasting_events : Array[Event] = []


func _ready() -> void:
	add_to_group("load", true)
	DayNightCycleController.day_started.connect(on_new_day)


## Called when a new event should happend. It will trigger a signal. The event will be removed from
## [member pased_events], so the same event can't be in both arrays at the same time
func push_new_event(event : Event) -> void:
	if AppManager.game_match_running == false:
		return
	if event == null:
		return
	print("New event pushed : %s" % [event.event_name])
	new_event_pushed.emit(event)
	
	if event.event_is_trigger:
		return
	
	current_events.append(event)
	# Cant be in both arrays at the same time
	if event in passed_events:
		passed_events.erase(event)
	
	if event.is_one_day_only:
		one_day_lasting_events.append(event)
	
	SaveDataServer.save_events()


## Tries to finish an event on [member current_event] array.
## Will do nothing if the event is not in the array
func finish_event(event : Event) -> void:
	if AppManager.game_match_running == false:
		return
	if current_events.has(event):
		print("%s event has finished" % [event.event_name])
		current_events.erase(event)
		one_day_lasting_events.erase(event)
		passed_events.append(event)
		event_finished.emit(event)
		SaveDataServer.save_events()


##This is separated from [method finish_event] so the load and save system
##can add events to the list on load without triggering the signal and without passing
##through the [member current_events] array
func add_passed_event_to_list(event : Event) -> void:
	passed_events.append(event)


func reset() -> void:
	passed_events.clear()
	current_events.clear()
	one_day_lasting_events.clear()


func on_new_day() -> void:
	if AppManager.game_match_running == false:
		return
	for event in one_day_lasting_events:
		if current_events.has(event):
			finish_event(event)
	one_day_lasting_events.clear()


func _load(data : SavedData) -> void:
	current_events.clear()
	for event in data.current_evets:
		var temp = EventVault.get_event_by_string(event)
		if temp != null:
			current_events.append(temp)
	
	passed_events.clear()
	for event in data.passed_events:
		var temp = EventVault.get_event_by_string(event)
		if temp:
			passed_events.append(temp)
	
	one_day_lasting_events.clear()
	for event in data.one_day_lasting_events:
		var temp = EventVault.get_event_by_string(event)
		if temp:
			one_day_lasting_events.append(temp)
