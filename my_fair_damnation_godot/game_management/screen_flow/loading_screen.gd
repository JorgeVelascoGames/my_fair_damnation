extends Control
class_name LoadingScreen

signal new_sceen_loaded(scene : Node)

@onready var fade: ColorRect = $Fade
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_loading := false
var scene_loading
var keep_playing_sound := false


func _ready() -> void:
	fade.hide()
	hide()
	set_process(false)


func load_scene(scene : PackedScene, play_sound := false):
	if is_loading:
		return
	AppManager.game_match_running = false
	audio_stream_player.play()
	keep_playing_sound = play_sound
	set_process(true)
	# Mostrar y preparar el fade
	fade.show()
	fade.modulate.a = 1.0
	
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	is_loading = true
	show()
	scene_loading = scene.resource_path
	ResourceLoader.load_threaded_request(scene.resource_path)


func _process(delta: float) -> void:
	if not is_loading:
		return
	
	if ResourceLoader.THREAD_LOAD_LOADED:
		is_loading = false
		await get_tree().create_timer(2).timeout
		var new_scene = ResourceLoader.load_threaded_get(scene_loading).instantiate()
		new_sceen_loaded.emit(new_scene)
		hide()
		set_process(false)
		if not keep_playing_sound:
			audio_stream_player.stop()
