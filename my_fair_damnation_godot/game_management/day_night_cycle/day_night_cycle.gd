extends Node

signal day_started
signal night_started
signal doom_started
signal player_sleeps_all_night

enum period{
	DAY,
	NIGHT,
	DOOM
}
enum environment_used{
	DAY,
	NIGHT
}

const PLAYER_REST_TO_DAY = preload("res://events/events_resources/game_flow_events/player_rest_to_day.tres")
const PLAYER_REST_TO_MIDNIGHT = preload("res://events/events_resources/game_flow_events/player_rest_to_midnight.tres")
const WORLD_ENVIRONMENT_DAY = preload("res://assets/world_environment_day.tres")
const WORLD_ENVIRONMENT_NIGHT = preload("res://assets/world_environment_night.tres")
const BAD_ENDING = preload("uid://c366j5d2i4jc2")

const DAY = period.DAY
## Doom is the time between the warning and the exahustion
const DOOM = period.DOOM
const NIGHT = period.NIGHT

const MAX_DAYS := 15

@export var day_count := 0
@export var day_duration_in_seconds := 630.00
@export var night_duration_in_seconds := 450.00
@export var doom_duration_in_seconds := 40.00
@export var madness_cost_per_second := 10.00

@onready var day_night_cycle_timer: Timer = $DayNightCycleTimer

#Events
## Pushed to determine that we are at night 
const NIGHT_TIME = preload("res://events/events_resources/game_flow_events/night_time.tres")
const START_GAME = preload("res://events/events_resources/game_flow_events/start_game.tres")

var exhausted := false
var current_period := DAY
var current_environment := environment_used.DAY
var environment : WorldEnvironment 
var player : Player

## For the player when day time is about to run out
const day_time_over_messages = [
	"day_time_over_001",
	"day_time_over_002",
	"day_time_over_003",
	"day_time_over_004",
	"day_time_over_005",
	"day_time_over_006",
	"day_time_over_007"
]

## For the player when night time is about to run out
const night_time_over_messages = [
	"night_time_over_001",
	"night_time_over_002",
	"night_time_over_003",
	"night_time_over_004",
	"night_time_over_005",
	"night_time_over_006"
]

## Showed to the player when day or night time is over
const exhaustion_messages = [
	"run_exhaustion_001",
	"run_exhaustion_002",
	"run_exhaustion_003",
	"run_exhaustion_004",
	"run_exhaustion_005",
	"run_exhaustion_006",
	"run_exhaustion_007"
]


func _ready() -> void:
	EventManager.new_event_pushed.connect(_on_event)


func _process(delta: float) -> void:
	if AppManager.game_match_running == false:
		day_night_cycle_timer.stop()
		return
	SaveDataServer.save_day_night_cicle()
	if exhausted:
		player.madness.add_madness_raw(madness_cost_per_second * delta)


func start_new_day() -> void:
	print("A new day begins...")
	current_period = DAY
	exhausted = false
	day_night_cycle_timer.start(day_duration_in_seconds)
	day_count += 1
	day_started.emit()
	
	if day_count >= MAX_DAYS:
		EventManager.push_new_event(BAD_ENDING)
		return
	
	if environment == null:
		environment = get_environment_node()
	environment.environment = WORLD_ENVIRONMENT_DAY
	SaveDataServer.save_day_night_cicle()
	current_environment = environment_used.DAY
	await get_tree().create_timer(1).timeout
	if player == null:
		player = await PathfindingManager.get_player()
	await get_tree().create_timer(1).timeout
	SaveDataServer.save_game()
	await get_tree().process_frame
	SaveDataServer.save_control_point()


func start_new_night() -> void:
	current_period = NIGHT
	exhausted = false
	night_started.emit()
	day_night_cycle_timer.start(night_duration_in_seconds)
	environment.environment = WORLD_ENVIRONMENT_NIGHT
	SaveDataServer.save_day_night_cicle()
	current_environment = environment_used.NIGHT


func _on_day_night_cycle_timer_timeout() -> void:
	var message := ""
	var message_b := ""
	
	match current_period:
		DAY:
			message = day_time_over_messages.pick_random()
			message_b = "day_time_over"
			current_period = DOOM
			day_night_cycle_timer.start(doom_duration_in_seconds)
			doom_started.emit()
		NIGHT:
			message = night_time_over_messages.pick_random()
			message_b = "night_time_over"
			current_period = DOOM
			day_night_cycle_timer.start(doom_duration_in_seconds)
			doom_started.emit()
		DOOM:
			message = exhaustion_messages.pick_random()
			message_b = "time_exhaustion"
			exhausted = true
	player.player_ui.display_gameplay_text(tr(message) + "\n" + tr(message_b))
	SaveDataServer.save_day_night_cicle()


func reset() -> void:
	day_count = 0
	exhausted = false
	current_period = DAY
	current_environment = environment_used.DAY


func get_environment_node() -> WorldEnvironment:
	return get_tree().get_first_node_in_group("world_environment")


func _on_event(event : Event) -> void:
	match event:
		PLAYER_REST_TO_DAY:
			start_new_day()
		PLAYER_REST_TO_MIDNIGHT:
			start_new_night()


func force_end_timer() -> void:
	day_night_cycle_timer.stop()
	day_night_cycle_timer.timeout.emit()


func _load(data : SavedData) -> void:
	day_count = data.day_count
	current_period = data.day_night_period as period
	if environment == null:
		get_environment_node()
	if data.time_remaining > 0:
		day_night_cycle_timer.start(data.time_remaining)
	if current_period == DOOM and data.time_remaining <= 0:
		exhausted = true
	
	environment = get_environment_node()
	current_environment = data.environment as environment_used
	if current_environment == environment_used.DAY:
		environment.environment = WORLD_ENVIRONMENT_DAY
	else:
		environment.environment = WORLD_ENVIRONMENT_NIGHT
