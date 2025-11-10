extends Node3D

##If any event in this array is in the current_events array on the EventManager,
##the box won't show up at night
@export var block_events : Array[Event] = [] 
@export var frank_npc : Npc
@export var frank_instance_to_block_gun : NpcInstance

@onready var interactable: Interactable = $EnvironmentConversation/Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	hide_box()
	interactable.interacted.connect(show_animation)
	DayNightCycleController.day_started.connect(hide_box)
	DayNightCycleController.night_started.connect(show_box)


func show_animation() -> void:
	animation_player.play("box_open")


func hide_box() -> void:
	hide()
	interactable.monitorable = false
	animation_player.play("box_close")


func show_box() -> void:
	await get_tree().create_timer(2).timeout #So it awaits any possible event before checking next loop
	for event in block_events:
		if EventManager.current_events.has(event):
			return
	
	if frank_npc.npc_instance_controller.active_instance == frank_instance_to_block_gun:
		return #Para que la pistola no aparezca cuando frank
	
	show()
	interactable.monitorable = true
	animation_player.play("box_close")


func _load(data) -> void:
	await get_tree().process_frame
	if DayNightCycleController.current_period == DayNightCycleController.NIGHT:
		show_box()
	else:
		hide_box()
