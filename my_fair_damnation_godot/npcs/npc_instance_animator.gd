extends Node
class_name NpcInstanceAnimator

enum animation_modes{
	BY_REPUTATION,
	BY_EVENT,
	BY_DAY
}

## If false, animations will not be affected by that
@export var active := false
@export var npc : Npc
## This determines the type of conditions affecting the animation state
@export var animation_mode : animation_modes

@export var animation_player : AnimationPlayer
@export var model : Node3D

## If the key event is on the current event array, the animation with the given
## name will be played on day start. It will work for the first even found
@export var animation_by_event_priority : Dictionary[Event, String] = {}
##If the key animation name is provided, the instance will be set to the given position when the animation
##change happens
@export var animation_position : Dictionary[String, Vector3] = {}
@export var animation_by_day : Dictionary[int,String] = {}
##If the key animation name is provided, the instance will be set to the given rotation when the animation
##change happens
@export var animation_rotation : Dictionary[String, Vector3] = {}

@export var animation_hostile : String
@export var animation_neutral : String
@export var animation_positive : String


func select_animation():
	if not active:
		return
	if animation_mode == animation_modes.BY_REPUTATION:
		match ReputationManager.get_reputation_level(npc.npc_reputation.get_reputation_towards_player()):
			ReputationManager.HOSTILE:
				animation_player.play(animation_hostile)
			ReputationManager.NEUTRAL:
				animation_player.play(animation_neutral)
			ReputationManager.POSITIVE:
				animation_player.play(animation_positive)
		place_animation()
		return 
	
	if animation_mode == animation_modes.BY_DAY:
		for day in animation_by_day.keys():
			if day > DayNightCycleController.day_count:
				animation_player.play(animation_by_day[day])
				place_animation()
				return
	
	if animation_mode != animation_modes.BY_EVENT:
		return
	
	for event in EventManager.current_events:
		if not animation_by_event_priority.keys().has(event):
			continue
		var animation_name = animation_by_event_priority[event]
		if animation_player.has_animation(animation_name):
			animation_player.play(animation_name)
			place_animation()


##This will put the model on a given position and rotation if the key value pair matches
func place_animation() -> void:
	var animation_name : String = animation_player.current_animation
	if animation_position[animation_name]:
		model.position = animation_position[animation_name]
	if animation_rotation[animation_name]:
		model.rotation = animation_rotation[animation_name]
