extends NpcInstance

const NEIGHBOOR_SITTING_COL = preload("uid://dkvqox5nf2mg3")
const NEIGHBOOR_DEPRAVED_COL = preload("uid://c5ra3cph4d0it")

@export var skyler_photos : Item

@export var depraved_position : Vector3
@export var depraved_rotation: Vector3
@export var sitting_position : Vector3
@export var sittin_rotation : Vector3
@onready var collision_shape_3d: CollisionShape3D = $Interactable/CollisionShape3D
@onready var normal_idle_stream_player_3d: AudioStreamPlayer3D = $NpcInstanceAudioController/NormalIdleStreamPlayer3D
@onready var idle_depraved_audio_stream_player_3d: AudioStreamPlayer3D = $NpcInstanceAudioController/IdleDepravedAudioStreamPlayer3D


func _activate_instance() -> void:
	super()
	if player.player_inventory.items.has(skyler_photos):
		global_position = sitting_position
		global_rotation.y = deg_to_rad(-90)
		animation_player.play("idle_sit")
		npc_static_body_3d.hide()
		collision_shape_3d.shape = NEIGHBOOR_SITTING_COL
		idle_depraved_audio_stream_player_3d.stop()
		normal_idle_stream_player_3d.play()
	else:
		global_position = depraved_position
		global_rotation.y = deg_to_rad(180)
		animation_player.play("idle_depraved")
		npc_static_body_3d.show()
		collision_shape_3d.shape = NEIGHBOOR_DEPRAVED_COL
		idle_depraved_audio_stream_player_3d.play()
		normal_idle_stream_player_3d.stop()
