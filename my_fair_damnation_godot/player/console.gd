extends Control
class_name Console

@onready var console_line_edit: LineEdit = %ConsoleLineEdit
@onready var current_events_label: Label = %CurrentEventsLabel
@onready var passed_events_label: Label = %PassedEventsLabel
@onready var day_time_label: Label = %DayTimeLabel
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D

var remove_madness_code := "remove_madness_"
var add_maddnes_code := "add_madness_"

var player : Player


func _ready() -> void:
	directional_light_3d.hide()
	hide()
	player = await PathfindingManager.get_player()


func open_console() -> void:
	show()
	populate_events_label()


func close_console() -> void:
	hide()
	current_events_label.text = ""
	passed_events_label.text = ""


func _process(_delta: float) -> void:
	var controller := DayNightCycleController
	if controller == null:
		return
	update_day_time_label()


func update_day_time_label() -> void:
	var controller := DayNightCycleController
	if controller == null:
		return

	var day := controller.day_count
	var period_name := ""
	match controller.current_period:
		controller.DAY:
			period_name = "DÍA"
		controller.NIGHT:
			period_name = "NOCHE"
		controller.DOOM:
			period_name = "AGOTAMIENTO"
		_:
			period_name = "DESCONOCIDO"

	var seconds_left := int(controller.day_night_cycle_timer.time_left)
	
	day_time_label.text = "Día: %d\nPeriodo: %s\nTiempo restante: %ds" % [day, period_name, seconds_left]


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		process_text()


func process_text() -> void:
	var console_comand := console_line_edit.text
	console_line_edit.text = ""
	if console_comand == "killme":
		player.madness.player_dies()
		return
	if console_comand == "End period":
		DayNightCycleController.force_end_timer()
		return
	
	if console_comand == "Godmode":
		@warning_ignore("standalone_expression")
		AppManager.godmode != AppManager.godmode
		return
	
	if console_comand == "Get all items":
		player.player_inventory.add_all_items()
		return
	
	
	if console_comand == "Teleport":
		var marker = get_tree().get_first_node_in_group("player_teleport_debug")
		player.position = marker.global_position
		return
	
	if console_comand == "Light up":
		directional_light_3d.visible = !directional_light_3d.visible
		return
	
	if console_comand.contains(add_maddnes_code):
		player.madness.add_madness(console_comand.to_int())
		return
	
	if console_comand.contains(remove_madness_code):
		player.madness.substract_madness(console_comand.to_int())
		return
	
	for event : Event in EventVault.all_events:
		if event.event_name == console_comand:
			if EventManager.current_events.has(event):
				EventManager.finish_event(event)
				return
			else:
				EventManager.push_new_event(event)
				return

	
	for item : Item in ItemVault.all_items:
		if item.item_name == console_comand:
			player.player_inventory.give_item(item)
	
	# Print de variable de SavedData
	var var_name := console_comand.strip_edges()

	# Comprobar si la propiedad existe en SaveData
	var saved_data := SaveDataServer.local_saved_data
	var properties := saved_data.get_property_list()

	for property in properties:
		if property.name == var_name:
			var value = saved_data.get(var_name)
			print("[GodMode] SavedData.%s: %s" % [var_name, str(value)])
			return

	print("[GodMode] No existe la variable '%s' en SavedData" % var_name)


func populate_events_label() -> void:
	current_events_label.text = "The following events are on the current_events array:"
	passed_events_label.text =  "The following events are on the current_events array:"
	for event in EventManager.current_events:
		current_events_label.text += "\n " + event.event_name
	for event in EventManager.passed_events:
		passed_events_label.text += "\n " +event.event_name
