extends CharacterBody3D
class_name Player


@export var fall_multiplier : = 2.5
@export var camera_sensibility := 1.2
## To teleport to the room
@export var get_inside_room_door : TransitionDoor
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Private variables
var mouse_motion := Vector2.ZERO

## While equiped, the flashlight can be turned on
@export var flashlight_item : Item

#Components
@onready var player_ui: PlayerUI = %PlayerUI
@onready var camera_pivot = %CameraPivot
@onready var player_state_machine: PlayerStateMachine = %PlayerStateMachine
@onready var player_interaction_manager: PlayerInteractionManager = $PlayerInteractionManager
@onready var player_conversation_controller: PlayerConversationController = $PlayerConversationController
@onready var player_inventory: PlayerInventory = $PlayerInventory
@onready var player_audio_streamer: AudioStreamPlayer = $Audio/PlayerAudioStreamer
@onready var player_audio: PlayerAudio = $PlayerAudio
@onready var flashlight: SpotLight3D = $CameraPivot/WorldCamera/Flashlight
@onready var player_stamina: PlayerStamina = $PlayerStamina
@onready var madness: Madness = $Madness

##Used by the enemies to determine if they see the player
@onready var player_head_area: Area3D = $CameraPivot/WorldCamera/PlayerHeadArea


func _ready():
	set_up_player()
	player_ui.fade_in_black_screen()


##Prepares the player. Called on ready to be use on a new variation map
func set_up_player() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PathfindingManager.set_up_player(self)
	DayNightCycleController.player = self


func _physics_process(delta):
	process_gravity(delta)
	SaveDataServer.save_player_position(self)


func direction(delta) -> Vector3:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	return direction


func process_gravity(delta):
	if not is_on_floor():
		if velocity.y >=0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test") and OS.is_debug_build():
		player_state_machine.transition_to("PlayerGodmode", {})
	if event is InputEventMouseMotion:
		#print(event.relative)
		mouse_motion = -event.relative * 0.001
		#if Input.is_action_pressed("aim"):
			#mouse_motion *= aim_multiplier / 2


func start_conversation(conversation : NpcConversation, look_target : Node3D = null) -> void:
	var conversation_dicctionary = {
		"conversation" : conversation,
		"position" : look_target
	}
	player_state_machine.transition_to("PlayerConversation", conversation_dicctionary)


func try_turn_flashlight_on() -> void:
	if flashlight_item in player_inventory.items:
		flashlight.visible = !flashlight.visible


func _on_health_taken_damage(_dmg: int) -> void:
	pass


func _on_health_health_minimun_reached() -> void:
	#game_over_menu.game_over()
	pass


func _load(data : SavedData) -> void:
	if data.loaded_from_checkpoint:
		player_ui.display_gameplay_text("%s %d" % [tr("morning_of"), DayNightCycleController.day_count])
	global_position = data.player_position
	global_position.y += 0.3
	rotation = data.player_rotation
	player_ui.fade_in_black_screen()
