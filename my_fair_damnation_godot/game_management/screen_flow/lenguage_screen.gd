extends Control
class_name LenguageScreen

var game_manager : GameManager


func _ready() -> void:
	game_manager = get_tree().root.get_node("Game")

	#$ColorRect.hide()


func change_localization(lenguage : String) -> void:
	TranslationServer.set_locale(lenguage)
	SaveDataServer.save_localization(lenguage)
	game_manager.screen_flow_manager.load_main_menu()


func _on_esp_button_pressed() -> void:
	change_localization("es")


func _on_eng_button_pressed() -> void:
	change_localization("en")


func _on_fr_button_pressed() -> void:
	change_localization("fr")


func _on_kr_button_pressed() -> void:
	change_localization("ko")


func _on_ch_button_pressed() -> void:
	change_localization("zh")


func _on_rs_button_pressed() -> void:
	change_localization("ru")


func _on_jp_button_pressed() -> void:
	change_localization("ja")


func _on_pol_button_pressed() -> void:
	change_localization("pl")
