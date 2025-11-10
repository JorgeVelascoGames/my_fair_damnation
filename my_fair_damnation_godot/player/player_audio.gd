extends Node
class_name PlayerAudio

@export var walking_footsteps_timer := 0.88
@export var running_footsteps_timer := 0.54

@onready var item_audio_streamer: AudioStreamPlayer = $ItemAudioStreamer
@onready var footsteps_audio_stream_player: AudioStreamPlayer = $FootstepsAudioStreamPlayer
@onready var footsteps_timer: Timer = $FootstepsTimer
@onready var get_item_audio_stream_player: AudioStreamPlayer = $GetItemAudioStreamPlayer
@onready var drop_item_audio_stream_player: AudioStreamPlayer = $DropItemAudioStreamPlayer
@onready var open_inventory_audio_stream_player: AudioStreamPlayer = $OpenInventoryAudioStreamPlayer
@onready var close_inventory_audio_stream_player: AudioStreamPlayer = $CloseInventoryAudioStreamPlayer
@onready var gun_load_audio_streamer: AudioStreamPlayer = $GunLoadAudioStreamer
@onready var gun_no_ammo_load_audio_streamer: AudioStreamPlayer = $GunNoAmmoLoadAudioStreamer
@onready var gun_shoot_audio_streamer: AudioStreamPlayer = $GunShootAudioStreamer
@onready var gun_shoot_and_hit_audio_streamer: AudioStreamPlayer = $GunShootAndHitAudioStreamer
@onready var player_hit_audio_stream_player: AudioStreamPlayer = $PlayerHitAudioStreamPlayer


func _ready() -> void:
	footsteps_timer.timeout.connect(play_footstep_sound)


func start_footsteps() -> void:
	footsteps_timer.start(walking_footsteps_timer)


func start_running() -> void:
	footsteps_timer.start(running_footsteps_timer)


func stop_footsteps() -> void:
	footsteps_timer.stop()


func play_footstep_sound() -> void:
	footsteps_audio_stream_player.play()


func get_item() -> void:
	get_item_audio_stream_player.play()


func drop_item() -> void:
	drop_item_audio_stream_player.play()


func open_inventory() -> void:
	open_inventory_audio_stream_player.play()


func close_inventory() -> void:
	close_inventory_audio_stream_player.play()


func shoot() -> void:
	gun_shoot_audio_streamer.play()


func try_shoot_no_bullets() -> void:
	gun_no_ammo_load_audio_streamer.play()


func shoot_hit() -> void:
	gun_shoot_and_hit_audio_streamer.play()


func load_gun() -> void:
	gun_load_audio_streamer.play()


func hit_scream() -> void:
	player_hit_audio_stream_player.play()
