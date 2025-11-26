extends Node3D
class_name TransitionDoor

## This is used to transport the player between rooms
## Inside the core level

signal transitioned_throught_door

## The player will be transported here
@export var transition_time := 1.5
## Item necessary to open it
@export var key_item : Item
##The name of the area we transition. This will be saved directly in the save system
@export var area_name : String

@onready var destination_marker_3d: Marker3D = $DestinationMarker3D
#Overlay
@onready var transition_canvas_layer: CanvasLayer = $TransitionCanvasLayer
@onready var fade_effect: ColorRect = $TransitionCanvasLayer/Control/FadeEffect
@onready var texture_background: ColorRect = $TransitionCanvasLayer/Control/TextureBackground
@onready var texture_rect: TextureRect = $TransitionCanvasLayer/Control/TextureRect
#Audio
@onready var unlock_audio_stream_player: AudioStreamPlayer = $UnlockAudioStreamPlayer
@onready var close_audio_stream_player: AudioStreamPlayer = $CloseAudioStreamPlayer
@onready var locked_door_audio_stream_player_3d: AudioStreamPlayer3D = $LockedDoorAudioStreamPlayer3D

var player : Player


func _ready() -> void:
	player = await PathfindingManager.get_player()
	if is_instance_valid(player):
		return


func transition() -> void:
	SaveDataServer.save_new_player_area(area_name)
	transitioned_throught_door.emit()
	player.player_state_machine.transition_to("PlayerParalize", {})
	# Paso 1: Mostrar todos los elementos de la transición
	transition_canvas_layer.visible = true
	fade_effect.visible = true
	texture_background.visible = true
	texture_rect.visible = true
	unlock_audio_stream_player.play()
	player.global_position = destination_marker_3d.global_position
	player.rotation = destination_marker_3d.rotation
	# Paso 2: Esperar el tiempo de transición
	await get_tree().create_timer(transition_time).timeout
	
	# Paso 3: Ocultar elementos fijos
	texture_background.visible = false
	texture_rect.visible = false
	
	# Paso 4: Hacer fundido del FadeEffect (alfa a 0 en 0.7s)
	var tween := create_tween()
	tween.tween_property(fade_effect, "modulate:a", 0.0, 0.7)
	close_audio_stream_player.play()
	await tween.finished
	
	# Ocultar el FadeEffect completamente tras el fundido
	fade_effect.visible = false
	transition_canvas_layer.visible = false
	if player.player_state_machine.state.name == "PlayerParalize":
		player.player_state_machine.transition_to("PlayerIdle", {})


func _on_interactable_interacted() -> void:
	if key_item != null and not key_item in player.player_inventory.items:
		player.player_ui.display_gameplay_text(tr("door_escape_locked"))
		locked_door_audio_stream_player_3d.play()
		return
	transition()
