extends NpcInstanceController

@export var first_instance : NpcInstance
@export var basement_instance : NpcInstance
@export var basement_key : Item
@export var show_up_event : Event
@export var frank_enemy_controller : FrankEnemiesController

@export var hide_instances_event : Event

var player : Player


func _ready() -> void:
	super()
	await get_tree().process_frame
	player = await PathfindingManager.get_player()


##Triggers once daytime starts. This should be override
func manage_instances_on_day() -> void:
	if not player.player_inventory.items.has(basement_key):
		_activate_instance(basement_instance)


##Triggers once nightime starts. This should be override
func manage_instances_on_night() -> void:
	if player.player_inventory.items.has(basement_key):
		disable_all_instances()
		return
	if DayNightCycleController.day_count < 3:
		disable_all_instances()
		return
		#TODO crear un manager para que se desactiven los enemigos
	_activate_instance(first_instance)
	await get_tree().process_frame
	frank_enemy_controller._on_day()#Disable all
	await get_tree().create_timer(3).timeout
	frank_enemy_controller._on_day()#Mira ya porseacaso


func on_event_triggered(event : Event) -> void:
	if event == hide_instances_event:
		disable_all_instances()
