extends Node3D

@export var enter_basement_door : TransitionDoor
@export var exit_basement_door : TransitionDoor

@onready var day_music_audio_stream_player: AudioStreamPlayer = $DayMusicAudioStreamPlayer
@onready var doom_music_audio_stream_player: AudioStreamPlayer = $DoomMusicAudioStreamPlayer
@onready var sewers_audio_stream_player: AudioStreamPlayer = $SewersAudioStreamPlayer


func _ready() -> void:
	enter_basement_door.transitioned_throught_door.connect(on_enter_basement)
	exit_basement_door.transitioned_throught_door.connect(on_exit_basement)
	DayNightCycleController.day_started.connect(on_day_started)
	DayNightCycleController.night_started.connect(on_night_started)
	DayNightCycleController.doom_started.connect(on_doom_started)


func _process(_delta: float) -> void:
	await get_tree().create_timer(2).timeout
	if day_music_audio_stream_player.playing:
		SaveDataServer.save_day_music_playback_position(day_music_audio_stream_player.get_playback_position())


func on_day_started() -> void:
	day_music_audio_stream_player.play()
	doom_music_audio_stream_player.stop()


func on_doom_started() -> void:
	doom_music_audio_stream_player.play()


func on_night_started() -> void:
	day_music_audio_stream_player.stop()
	doom_music_audio_stream_player.stop()


func on_enter_basement() -> void:
	if DayNightCycleController.current_period == DayNightCycleController.DAY:
		SaveDataServer.save_day_music_playback_position(day_music_audio_stream_player.get_playback_position())
	day_music_audio_stream_player.stop()
	doom_music_audio_stream_player.stop()
	sewers_audio_stream_player.play()


func on_exit_basement() -> void:
	sewers_audio_stream_player.stop()
	if DayNightCycleController.current_period == DayNightCycleController.DAY:
		day_music_audio_stream_player.play(SaveDataServer.local_saved_data.day_music_playback_position)
	if DayNightCycleController.current_period == DayNightCycleController.DOOM:
		doom_music_audio_stream_player.play()


func _load(data : SavedData) -> void:
	await get_tree().create_timer(.5).timeout
	
	if data.player_area == "Basement":
		sewers_audio_stream_player.play()
		return
	
	if not EventManager.current_events.has(preload("uid://irwpbrn0k8ys")):
		return #Esto es para que al cargar partida antes de el primer dia no suene la musica
	
	match DayNightCycleController.current_period:
		DayNightCycleController.DAY:
			day_music_audio_stream_player.play(data.day_music_playback_position)
		DayNightCycleController.DOOM:
			doom_music_audio_stream_player.play()
