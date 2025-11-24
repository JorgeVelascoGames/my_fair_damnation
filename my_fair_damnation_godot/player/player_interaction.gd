extends Node
class_name PlayerInteractionManager

@onready var interact_raycast: RayCast3D = $"../CameraPivot/WorldCamera/InteractRaycast"
@onready var player_interacting: PlayerInteracting = $"../PlayerStateMachine/PlayerInteracting"

var current_interactable : Interactable


func try_interact() -> void:
	var collision = interact_raycast.get_collider()
	print(collision)
	print("AAAAAAAAAAAAAAAAAAAAAÑSDJFÑAOSFJIAÑSOFJIAÑSOJIFASOÑ")
	if collision is not Interactable:
		return
	
	current_interactable = collision
	if current_interactable.interaction_duration > 0.0:
		owner.player_state_machine.transition_to("PlayerInteracting", {
			"position" : current_interactable.global_position,
			"duration" : current_interactable.interaction_duration
		})
		current_interactable.start_interaction()
		return
	interact()


func try_get_interactable() -> Interactable:
	var collision = interact_raycast.get_collider()
	if collision is Interactable:
		return collision
	return null


func interact() -> void:
	if current_interactable:
		current_interactable.interact()
		current_interactable = null


func cancel_interaction() -> void:
	if current_interactable:
		current_interactable.interrupt_interaction()
		current_interactable = null
