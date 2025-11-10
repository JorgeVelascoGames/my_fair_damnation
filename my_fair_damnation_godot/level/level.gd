extends Node3D
class_name Level


func _ready() -> void:
	start_game()


func start_game() -> void:
	await get_tree().process_frame
	AppManager.game_match_running = true
	get_tree().root.get_node("Game")._on_loaded_level(self)
