extends Node3D
class_name GameManager

signal fresh_game_started
signal load_game_started

@onready var screen_flow_manager: ScreenFlowManager = %ScreenFlowManager

var level : Level
var is_fresh_game := true


func _ready() -> void:
	#var data = SaveDataServer.get_saved_data()
	#if data != null and not data.file_virgin:
		#TranslationServer.set_locale(data.lenguage)
		#screen_flow_manager.load_main_menu()
		#return
	screen_flow_manager.load_lenguage_screen() ##To avoid translation bugs, we always pick lenguage, not like its a big deal


func _on_loaded_level(_level : Level) -> void:
	level = _level
	if not is_fresh_game:
		SaveDataServer.load_level()
		return
	SaveDataServer.saving = true
