extends Node3D
class_name EnemyAudio

@export var footsteps_walking_timer := .56
@export var footsteps_chasing_timer := .78

@onready var footsteps_audio_stream_player_3d: AudioStreamPlayer3D = $FootstepsAudioStreamPlayer3D
@onready var attack_audio_stream_player_3d: AudioStreamPlayer3D = $AttackAudioStreamPlayer3D
@onready var stun_audio_stream_player_3d: AudioStreamPlayer3D = $StunAudioStreamPlayer3D
@onready var growl_audio_stream_player_3d: AudioStreamPlayer3D = $GrowlAudioStreamPlayer3D

@onready var footsteps_timer: Timer = $FootstepsTimer


func _ready() -> void:
	footsteps_timer.timeout.connect(footstep_sound)


func start_footsteps() -> void:
	footsteps_timer.start(footsteps_walking_timer)


func start_footsteps_chase() -> void:
	footsteps_timer.start(footsteps_chasing_timer)


func stop_footsteps() -> void:
	footsteps_timer.stop()


func play_attack() -> void:
	attack_audio_stream_player_3d.play()


func play_stun() -> void:
	stun_audio_stream_player_3d.play()


func play_growl() -> void:
	growl_audio_stream_player_3d.play()


func footstep_sound() -> void:
	footsteps_audio_stream_player_3d.play()
