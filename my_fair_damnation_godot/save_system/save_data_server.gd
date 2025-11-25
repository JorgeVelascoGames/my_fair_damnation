extends Node

##This singleton manages the loading and saving of data.

# This is to make sure the data is saved properly, in case multiple
# saves are trying to be done at once, resulting in lost data

@export var local_saved_data : SavedData
@export var control_point_save_data : SavedData

var saving := false


func _ready() -> void:
	#$Timer.timeout.connect(save_game)
	#must prepare the load file
	local_saved_data = SavedData.new()
	var save_data = get_saved_data()
	if save_data == null:
		create_fresh_save()
		return
	# Loading the data this way is necessary, otherwhise calling a save could
	# Override everything with null values
	local_saved_data = save_data.duplicate()
	control_point_save_data = local_saved_data.duplicate(true)
	AppManager.load_settings(local_saved_data)


func is_save_data() -> bool:
	var saved_data : SavedData = load("user://savegame.tres")
	if saved_data == null:
		return false
	return true


##Returns the [SaveData] saved file
func get_saved_data() -> SavedData:
	var saved_data = load("user://savegame.tres")
	return saved_data


##Creates a new fresh save file
func create_fresh_save() -> void:
	var current_leanguage := local_saved_data.lenguage
	local_saved_data = SavedData.new()
	local_saved_data.lenguage = current_leanguage
	ResourceSaver.save(local_saved_data, "user://savegame.tres")


## Used when the level is loaded, will load all important information.
## Add any node to the "load" group and make sure it has a method _load in it.
## Said method will recieve the [SaveData] file with all the saved data
func load_level() -> void:
	var save_data = get_saved_data()
	if save_data == null:
		return
	
	get_tree().call_group("load", "_load", save_data)
	await get_tree().create_timer(2).timeout
	saving = true
	AppManager.load_settings(local_saved_data)


##Devuelve al menu principal, pero pudiendo volver a cargar desde el checkpoint
func load_control_point() -> bool:
	saving = false
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var save_data = control_point_save_data.duplicate(true)
	if save_data == null:
		saving = true
		return false
	
	save_data.loaded_from_checkpoint = true
	local_saved_data = save_data
	
	ResourceSaver.save(local_saved_data, "user://savegame.tres")
	
	var game_manager : GameManager = get_tree().root.get_node("Game")
	game_manager.is_fresh_game = false
	
	var flow_screen : ScreenFlowManager
	flow_screen = get_tree().get_first_node_in_group("screen_flow_manager")
	flow_screen.load_main_menu()
	
	return true


func save_npc_reputation(
id : NpcId, 
rep_with_player : int, 
rep_with_npcs : Dictionary[String, float]
) -> void:
	local_saved_data.reputation_with_player[id.npc_name] = rep_with_player
	local_saved_data.reputation_between_npcs[id.npc_name] = rep_with_npcs


func save_game() -> void:
	if not saving:
		return
	
	var new_saved_data = get_saved_data()
	if new_saved_data == null:
		new_saved_data = SavedData.new()
	
	local_saved_data.file_virgin = false
	local_saved_data.loaded_from_checkpoint = false
	new_saved_data = local_saved_data.duplicate()
	
	ResourceSaver.save(new_saved_data, "user://savegame.tres")


func save_control_point() -> void:
	control_point_save_data = local_saved_data.duplicate(true)


func save_events() -> void:
	local_saved_data.current_evets.clear()
	local_saved_data.passed_events.clear()
	local_saved_data.one_day_lasting_events.clear()
	
	for event in EventManager.current_events:
		local_saved_data.current_evets.append(event.event_name)
	for event in EventManager.passed_events:
		local_saved_data.passed_events.append(event.event_name)
	for event in EventManager.one_day_lasting_events:
		local_saved_data.one_day_lasting_events.append(event.event_name)


func save_inventory(inv : PlayerInventory) -> void:
	local_saved_data.inventory.clear()
	for item in inv.items:
		local_saved_data.inventory.append(item.item_name)


func save_player_position(player : Player) -> void:
	local_saved_data.player_position = player.global_position
	local_saved_data.player_rotation = player.global_rotation


func save_madness(amoutn : float) -> void:
	local_saved_data.player_madness = amoutn


func save_lights(id : int, state : bool) -> void:
	local_saved_data.lights_state[id] = state


func save_stamina(stamina : float, message_shown : bool) -> void:
	local_saved_data.stamina = stamina
	local_saved_data.exhaustion_message_shown = message_shown


func save_day_night_cicle() -> void:
	local_saved_data.day_night_period = DayNightCycleController.current_period
	local_saved_data.time_remaining = DayNightCycleController.day_night_cycle_timer.time_left
	local_saved_data.environment = DayNightCycleController.current_environment
	local_saved_data.day_count = DayNightCycleController.day_count


func save_dialogs(consumed_dialogs : Array[Dialog], once_per_day_dialogs : Array[Dialog], seen_dialogs : Array[Dialog]) -> void:
	for dialog in consumed_dialogs:
		local_saved_data.consumed_dialogs.append(dialog.dialog_id)
	
	for dialog in once_per_day_dialogs:
		local_saved_data.once_per_day_dialogs.append(dialog.dialog_id)
	
	for dialog in seen_dialogs:
		local_saved_data.seen_dialogs.append(dialog.dialog_id)


#Dont know why I do this instead of cleaning the array in the save_dialog method, but I fear a bug
func clean_once_per_day_dialogs() -> void:
	local_saved_data.once_per_day_dialogs.clear()
	save_game()


func save_localization(localization : String) -> void:
	local_saved_data.lenguage = localization


func save_npc_instance(id_name : String, instance : int, is_saved : bool) -> void:
	local_saved_data.npcs_current_instance[id_name] = instance
	local_saved_data.npcs_saved[id_name] = is_saved


func save_destructors(id: int) -> void:
	local_saved_data.descturctors_ids.append(id)


func save_filling_cabinets(id : int, state : bool) -> void:
	local_saved_data.filling_cabinets[id] = state


func save_message_displayers(id : int, state : bool) -> void:
	local_saved_data.message_displayers[id] = state


func save_volume(volume : float) -> void:
	local_saved_data.volume = volume
	save_game()


func save_day_music_playback_position(position : float) -> void:
	local_saved_data.day_music_playback_position = position


func save_new_player_area(area_name : String) -> void:
	local_saved_data.player_area = area_name
	save_game()
