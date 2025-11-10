extends Node3D
class_name NpcInstanceAudioController

@export var idle_sound_during_conversation := false

@onready var npc_idle_audio_stream_player_3d: AudioStreamPlayer3D = $NpcIdleAudioStreamPlayer3D
@onready var dialog_audio_stream_player_3d: AudioStreamPlayer3D = $DialogAudioStreamPlayer3D


func _on_instance_activated() -> void:
	npc_idle_audio_stream_player_3d.play()


func _on_instance_disabled() -> void:
	npc_idle_audio_stream_player_3d.stop()


func _on_start_conversation() -> void:
	if not idle_sound_during_conversation:
		npc_idle_audio_stream_player_3d.stop()


func _on_stop_conversation() -> void:
	npc_idle_audio_stream_player_3d.play()


func talk() -> void:
	#if dialog_audio_stream_player_3d.playing:
		#return
	dialog_audio_stream_player_3d.play()
