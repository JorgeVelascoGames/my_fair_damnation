extends PlayerComponent
class_name PlayerStamina


@export var max_stamina := 160.00
@export var stamina := 160.00
## The amount of stamina drained per second
@export var stamina_cost_per_second := 1.0
## Madness cost per second if stamina is exhausted
@export var madness_cost_per_second := 5.0

const PLAYER_REST_TO_DAY = preload("res://events/events_resources/game_flow_events/player_rest_to_day.tres")
const PLAYER_REST_TO_MIDNIGHT = preload("res://events/events_resources/game_flow_events/player_rest_to_midnight.tres")

var spending := false
var exhaustion_message_shown := false

var running_exhaustion_messages = [
	"run_exhaustion_001",
	"run_exhaustion_002",
	"run_exhaustion_003",
	"run_exhaustion_004",
	"run_exhaustion_005"
]


func _ready() -> void:
	stamina = max_stamina


func _process(delta: float) -> void:
	save_stamina()
	if not spending:
		return
	if stamina > 0.0:
		stamina -= stamina_cost_per_second * delta
		#print(stamina)
		return
	player.madness.add_madness_raw(madness_cost_per_second * delta)
	if not exhaustion_message_shown:
		exhaustion_message_shown = true
		player.player_ui.display_gameplay_text("%s \n %s" % [tr(running_exhaustion_messages.pick_random()), tr("run_exhaustion")])


func start_spending_stamina() -> void:
	spending = true


func stop_spending_stamina() -> void:
	spending = false



func save_stamina() -> void:
	SaveDataServer.save_stamina(stamina, exhaustion_message_shown)


func on_event_pushed(event : Event) -> void:
	if event == PLAYER_REST_TO_DAY or event == PLAYER_REST_TO_MIDNIGHT:
		stamina = max_stamina
		exhaustion_message_shown = false


func _load(data : SavedData) -> void:
	stamina = data.stamina
	exhaustion_message_shown = data.exhaustion_message_shown
