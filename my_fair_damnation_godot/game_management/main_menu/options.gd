extends Control

class_name OptionMenu

signal open_options_menu
signal close_options_menu

@onready var camera_sensibility_hslider: HSlider = %CameraSensibilityHSlider
@onready var volume_h_slider: HSlider = %VolumeHSlider
@onready var default: Button = %Default
@onready var close: Button = %Close
@onready var lenguage_button: Button = %LenguageButton
@onready var headbob_check_box: CheckBox = $OptionsCenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeadbobCheckBox


func _ready() -> void:
	hide()
	camera_sensibility_hslider.value_changed.connect(_on_camera_sensibility_hslider_value_changed)
	volume_h_slider.value = AppManager.volume
	headbob_check_box.button_pressed = AppManager.use_head_bob
	camera_sensibility_hslider.value = AppManager.camera_sensibility


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


func change_volume(value: float) -> void:
	AppManager.volume = value
	SaveDataServer.save_volume(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


func _on_close_pressed() -> void:
	close_options()


func _on_default_pressed() -> void:
	change_volume(0.00)
	volume_h_slider.value = 0.00
	camera_sensibility_hslider.value = 1.2
	AppManager.camera_sensibility = 1.2
	SaveDataServer.save_camera_sensibility(1.2)


func _on_volume_h_slider_value_changed(value: float) -> void:
	change_volume(value)


func _on_lenguage_button_pressed() -> void:
	var screen_flow: ScreenFlowManager
	screen_flow = get_tree().get_first_node_in_group("screen_flow_manager")
	screen_flow.load_lenguage_screen()


func _load(data: SavedData) -> void:
	volume_h_slider.value = data.volume


func _on_back_to_main_menu_pressed() -> void:
	close_options()
	var screen_flow: ScreenFlowManager
	screen_flow = get_tree().get_first_node_in_group("screen_flow_manager")
	screen_flow.load_main_menu()


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()


func _on_headbob_check_box_pressed() -> void:
	AppManager.use_head_bob = headbob_check_box.button_pressed
	SaveDataServer.save_use_head_bob(AppManager.use_head_bob)
	print("Headbob set to: ", AppManager.use_head_bob)


func _on_camera_sensibility_hslider_value_changed(value: float) -> void:
	AppManager.camera_sensibility = value
	SaveDataServer.save_camera_sensibility(value)
