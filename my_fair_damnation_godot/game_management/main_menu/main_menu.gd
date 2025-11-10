extends Node3D

@onready var black_screen_animator: AnimationPlayer = $BlackScreenAnimator
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var credits: ColorRect = $MainMenuUI/Credits
@onready var steam_button: Button = $MainMenuUI/MarginContainer/SteamButton
@onready var build_version_label: Label = $MainMenuUI/MarginContainer/BuildVersionLabel

var game_manager : GameManager

const VHS_EJECTED = preload("res://assets/audio/ambient/vhs_ejected.mp3")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not AppManager.is_demo:
		steam_button.hide()
		build_version_label.hide()
	game_manager = get_tree().root.get_node("Game")
	var data = SaveDataServer.get_saved_data()
	if data == null or data.file_virgin:
		$MainMenuUI/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/PlayButton.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if credits.visible:
			$MainMenuUI/Credits/CreditsAnimator.stop()
			credits.hide()


## Continues the last saved game
func _on_play_button_pressed() -> void:
	var data = SaveDataServer.get_saved_data()
	if data == null or data.file_virgin:
		SaveDataServer.create_fresh_save()
	else:
		game_manager.is_fresh_game = false # Just in case there is some problem with the save 
										   #system. If we load a fresh save, multiple values 
										   #will become empty or 0, like stamina
	audio_stream_player.stop()
	audio_stream_player.stream = VHS_EJECTED
	audio_stream_player.play()
	black_screen_animator.play_backwards("fade")
	await get_tree().create_timer(4.2).timeout
	audio_stream_player.stop()
	game_manager.screen_flow_manager.load_game()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_steam_button_pressed() -> void:
	if AppManager.store_link != "":
		OS.shell_open(AppManager.store_link)


func _on_credits_button_pressed() -> void:
	credits.show()
	$MainMenuUI/Credits/CreditsAnimator.play("roll_credits")


## Creates a new game
func _on_new_button_pressed() -> void:
	DayNightCycleController.reset()
	EventManager.reset()
	await get_tree().process_frame
	# We delete any potential progress
	SaveDataServer.create_fresh_save()
	game_manager.is_fresh_game = true
	
	audio_stream_player.stop()
	audio_stream_player.stream = VHS_EJECTED
	audio_stream_player.play()
	black_screen_animator.play_backwards("fade")
	await get_tree().create_timer(4.2).timeout
	audio_stream_player.stop()
	game_manager.screen_flow_manager.load_game()


func _on_options_button_pressed() -> void:
	$MainMenuUI/Options.open_options()
