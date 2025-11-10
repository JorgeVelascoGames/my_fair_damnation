extends Node3D
class_name MessageDisplayer

@export var message_displayer_id := 0
@export var messages : Array[String] = []
@export var interactable : Interactable
@export var player_catcher : PlayerCatcher
##Triggering any event on this array will activate the displayer
@export var events : Array[Event] = []
@export var delay := 0.0
##If true, the displayer will destroy itself after first use
@export var one_use := true
##Will show up only once a day
@export var daily_use := false
##Time of the day/night ciclye in which this will work
@export_enum("DAY", "NIGHT", "BOTH") var time_of_day = "BOTH"
##If it's not one use only, the cd between different shows
@export var cd := 10.0
##Chances of showing the message on detection. It triggers cd anyways, but won't 
##consume [member one_use]. It will, however, consume [member daily_use]
@export_range(0.0, 100.00) var probability := 100.00

@onready var cd_timer: Timer = $CDTimer

var player_ui : PlayerUI
var used_today := false


func _ready() -> void:
	await PathfindingManager.get_player()
	player_ui = PathfindingManager.player.player_ui
	if interactable:
		interactable.interacted.connect(display_message)
	if player_catcher:
		player_catcher.player_detected.connect(display_message)
	DayNightCycleController.day_started.connect(_on_new_day)
	EventManager.new_event_pushed.connect(_on_event)


func display_message() -> void:
	# Wait for the delay
	await get_tree().create_timer(delay).timeout
	
	# Check CD
	if cd_timer.time_left > 0.0:
		return
	
	# Check daily use
	if daily_use and used_today:
		return
	
	# Check time of the day
	if time_of_day == "DAY" and DayNightCycleController.current_period != DayNightCycleController.DAY:
		return
	if time_of_day == "NIGHT" and DayNightCycleController.current_period != DayNightCycleController.NIGHT:
		return
	
	# Start timer
	cd_timer.start(cd)
	
	#Daily use
	used_today = true
	
	var chance = randf_range(0, 100)
	if chance > probability:
		return
	
	player_ui.display_gameplay_text(tr(messages.pick_random()))
	
	save_state()
	
	if one_use:
		await get_tree().process_frame
		queue_free()


func _on_new_day() -> void:
	used_today = false


func _on_event(event : Event) -> void:
	if events.has(event):
		display_message()


func save_state() -> void:
	SaveDataServer.save_message_displayers(message_displayer_id, used_today)


func _load(data : SavedData) -> void:
	if not data.message_displayers.keys().has(message_displayer_id):
		return
	
	used_today = data.message_displayers[message_displayer_id]
	
	if used_today and one_use:
		queue_free()
