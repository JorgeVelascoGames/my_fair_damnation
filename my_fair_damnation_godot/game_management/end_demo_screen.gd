extends Control


func _on_exit_button_pressed() -> void:
	var screen_flow : ScreenFlowManager
	screen_flow = get_tree().get_first_node_in_group("screen_flow_manager")
	screen_flow.load_main_menu()


func _on_go_steam_button_pressed() -> void:
	if AppManager.store_link != "":
		OS.shell_open(AppManager.store_link)
