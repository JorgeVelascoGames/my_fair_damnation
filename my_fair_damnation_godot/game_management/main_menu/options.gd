extends Control
class_name OptionMenu

signal open_options_menu
signal close_options_menu

@onready var volume_h_slider: HSlider = %VolumeHSlider
@onready var default: Button = %Default
@onready var close: Button = %Close
@onready var lenguage_button: Button = %LenguageButton


func _ready() -> void:
	hide()
	volume_h_slider.value = AppManager.volume


func open_options() -> void:
	if visible:
		return
	show()
	open_options_menu.emit()


func close_options() -> void:
	if not visible:
		return
	hide()
	close_options_menu.emit()


func change_volume(value : float) -> void:
	AppManager.volume = value
	SaveDataServer.save_volume(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		close_options()


func _on_close_pressed() -> void:
	close_options()


func _on_default_pressed() -> void:
	change_volume(0.00)
	volume_h_slider.value = 0.00


func _on_volume_h_slider_value_changed(value: float) -> void:
	change_volume(value)


func _on_lenguage_button_pressed() -> void:
	var screen_flow : ScreenFlowManager
	screen_flow = get_tree().get_first_node_in_group("screen_flow_manager")
	screen_flow.load_lenguage_screen()


func _load(data : SavedData) -> void:
	volume_h_slider.value = data.volume


func _on_back_to_main_menu_pressed() -> void:
	close_options()
	var screen_flow : ScreenFlowManager
	screen_flow = get_tree().get_first_node_in_group("screen_flow_manager")
	screen_flow.load_main_menu()


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
