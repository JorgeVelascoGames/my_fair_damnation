extends NpcComponent
class_name NpcInstanceController

## Controlls which instance of the npc to show

signal instance_change(int)

enum night_behaviour{
	SLEEP,
	VANISH,
	NONE
}

const ENEMY_ID := 300
const SLEEP_ID := 400
const NULL_ID := 500

@export var main_instance : NpcInstance
@export var meds_event : Event
@export var missing_meds_message : String
@export_category("Night")
@export var behaviour_at_night : night_behaviour
@export var enemy_instance : Enemy
@export var sleeping_instance : NpcInstance
@export_category("Instance controll")
##If this is true and there is no match for instance at day, the [member main_instance]
##wil be activated. Otherwise, there will be no instance
@export var main_instance_as_default := true
@export var use_current_event_instance_array := false
@export var use_passed_event_instance_array := false
##If the key event is on the current events array on the event manager, 
##the pair instance will be activated at the beginning of the day. The first event
##to match will be only to count, and the code will not check more events after that one
@export var instance_by_current_event : Dictionary[Event, NpcInstance] = {}
##If the key event is on the passed events array on the event manager, 
##the pair instance will be activated at the beginning of the day. The first event
##to match will be only to count, and the code will not check more events after that one
@export var instance_by_passed_event : Dictionary[Event, NpcInstance] = {}
@export var free_event : Event

## The total ammount of different npc instances of this particular npc.
var current_instance_id := 0
var npc_instances : Array[NpcInstance]
var active_instance : NpcInstance
var last_daylight_instance : NpcInstance
var is_saved := false


func _ready() -> void:
	for inst in get_children():
		if inst is NpcInstance:
			npc_instances.append(inst)
	for instance in npc_instances:
		instance.npc = npc
	DayNightCycleController.player_sleeps_all_night.connect(manage_behaviour_sleep_all_night)
	await get_tree().process_frame
	
	if enemy_instance:
		enemy_instance.disable_instance()
	disable_all_instances()


##Manages which instance is activated. Pass nothing to set it to
##activate the null instance (character not existing)
func _activate_instance(instance : NpcInstance) -> void:
	if is_saved:
		print("%s is saved. Disabling all instances..." % npc.id.npc_name)
		disable_all_instances()
		return
	if instance == null:
		disable_all_instances()
		return
	if enemy_instance:
		enemy_instance.disable_instance()
	for inst in npc_instances:
		inst.disable_instance()
	
	current_instance_id = instance.instance_id
	active_instance = instance
	if instance == enemy_instance:
		current_instance_id = ENEMY_ID
	if instance == sleeping_instance:
		current_instance_id = SLEEP_ID
	instance._activate_instance()
	await get_tree().process_frame
	instance_change.emit(current_instance_id)
	save()


func _activate_enemy() -> void:
	if is_saved:
		return
	if not enemy_instance:
		return
	for instance in npc_instances:
		instance.disable_instance()
	current_instance_id = ENEMY_ID
	enemy_instance._activate_instance()
	save()
	print("Activate enemy: %s" % npc.id.npc_name)


##Triggers once daytime starts
func manage_instances_on_day() -> void:
	if is_saved:
		disable_all_instances()
		return
	calculate_meds_reputation_change()
	if use_current_event_instance_array:
		for event in instance_by_current_event.keys():
			if EventManager.current_events.has(event):
				_activate_instance(instance_by_current_event[event])
				last_daylight_instance = instance_by_current_event[event] #Esto se hace así para evitar problemas de carrera
				return
	
	if use_passed_event_instance_array:
		for event in instance_by_passed_event.keys():
			if EventManager.passed_events.has(event):
				_activate_instance(instance_by_passed_event[event])
				last_daylight_instance = instance_by_passed_event[event]
				return
	
	if main_instance_as_default:
		_activate_instance(main_instance)
		last_daylight_instance = main_instance
		return
	
	disable_all_instances()


##Triggers once nightime starts. This should be override
func manage_instances_on_night() -> void:
	if is_saved:
		disable_all_instances()
		return
	if npc.npc_reputation.reputation_with_player < 0 and enemy_instance:
		_activate_enemy()
		return
	match behaviour_at_night:
		night_behaviour.SLEEP:
			print("Activate sleep instance: %s" % npc.id.npc_name)
			activate_sleeping_instance()
		night_behaviour.VANISH:
			print("%s vanished in the night..." % npc.id.npc_name)
			disable_all_instances()
		night_behaviour.NONE:
			print("%s stays arround during night" % npc.id.npc_name)
			pass


func calculate_meds_reputation_change() -> void:
	if meds_event == null:
		print_rich("[color=red]No med reputation change: There is no med event for %s[/color]" % npc.id.npc_name)
		return
	if last_daylight_instance == null:
		print_rich("[color=red]No med reputation change: There is no npc instance from last day for %s[/color]" % npc.id.npc_name)
		return
	if not last_daylight_instance.need_meds:
		print_rich("[color=red]No med reputation change: %s doesn't need meds on last day instance[/color]" % npc.id.npc_name)
		return
	if EventManager.current_events.has(meds_event):
		EventManager.finish_event(meds_event)
		print_rich("[color=red]No med reputation change: %s got his/her meds[/color]" % npc.id.npc_name)
		return
	npc.npc_reputation.reputation_change(-15)
	print_rich("[color=red]%s didn't get meds last day: reputation has changed[/color]" % npc.id.npc_name)
	var player : Player = await PathfindingManager.get_player()
	var player_ui : PlayerUI = player.player.ui
	player_ui.display_gameplay_text(tr(missing_meds_message), 8.5)


func activate_sleeping_instance() -> void:
	if sleeping_instance:
		_activate_instance(sleeping_instance)


func activate_instance_by_id(id : int) -> void:
	if is_saved:
		disable_all_instances()
		return
	if id == ENEMY_ID:
		_activate_enemy()
		return
	
	for inst in npc_instances:
		if inst.instance_id == id:
			_activate_instance(inst)


##Triggers if player sleeps all night without starting the nightime
func manage_behaviour_sleep_all_night() -> void:
	pass


func on_event_pushed(event : Event) -> void:
	if event == free_event:
		is_saved = true
		save()
		dissolve_and_disapear_character()


func dissolve_and_disapear_character() -> void:
	await active_instance.disolve_mesh()
	disable_all_instances()


func on_day_start() -> void:
	manage_instances_on_day()


func on_night_start() -> void:
	manage_instances_on_night()


func save() -> void:
	SaveDataServer.save_npc_instance(npc.id.npc_name, current_instance_id, is_saved)


func disable_all_instances() -> void:
	print("%s Vanishes. Disabling all instances..." % npc.id.npc_name)
	for inst in npc_instances:
		inst.disable_instance()
	if enemy_instance:
		enemy_instance.disable_instance()
	last_daylight_instance = null
	current_instance_id = NULL_ID
	save()


func _load(data : SavedData) -> void:
	await get_tree().create_timer(1).timeout #Esto es para que de tiempo a cargar otras cosas necesarias como los eventos de los arrays y demas
	for id in data.npcs_current_instance.keys():
		if id == npc.id.npc_name:
			is_saved = data.npcs_saved[id]
			activate_instance_by_id(data.npcs_current_instance[id])
