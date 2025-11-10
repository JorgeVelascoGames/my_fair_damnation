extends Area3D
class_name Interactable

## Emmited on a long interactiong when the player starts the interaction
signal start_interacting
## Emitted on a long interaction if the player stops holding the button or is interrupted
## by other means
signal interrupt_interacting
## Emmited on a succesfull interaction
signal interacted

## If superior to 0, this interactable will be performed on a long interaction by
## holding the E button. This will make the player transition to the [PlayerInteracting]state
@export var interaction_duration := 0.0
## The text the player can read when interaction is aviable
@export_multiline var interactable_hint : String
### This events must be on the current event list for this interactable to be aviable
#@export var current_event_required : Array[Event] = []
### This events must be on the past event list for this interactable to be aviable
#@export var past_event_required : Array[Event] = []
### Those items are required for the area to work
#@export var required_items : Array[Item] = []
#
#@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var interacted_audio_stream_player_3d: AudioStreamPlayer3D = $InteractedAudioStreamPlayer3D
@onready var hold_interaction_audio_stream_player_3d: AudioStreamPlayer3D = $HoldInteractionAudioStreamPlayer3D


func interact() -> void:
	interacted.emit()
	hold_interaction_audio_stream_player_3d.stop()
	interacted_audio_stream_player_3d.play()


func start_interaction() -> void:
	start_interacting.emit()
	hold_interaction_audio_stream_player_3d.play()


func interrupt_interaction() -> void:
	interrupt_interacting.emit()
	hold_interaction_audio_stream_player_3d.stop()


#
#func check_if_interactable_aviable() -> void:
	#collision_shape_3d.disabled = !is_interactabel_aviable()
#
#
#func is_interactabel_aviable() -> bool:
	#if not current_event_required.is_empty():
		#for event in current_event_required:
			#if not EventManager.has(event):
				#return false
	#if not past_event_required.is_empty():
		#for event in past_event_required:
			#if not EventManager.passed_events.has(event):
				#return false
	#return true
