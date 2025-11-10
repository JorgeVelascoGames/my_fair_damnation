extends Node
class_name GameFlowController

## This node can be added to control the game flow (end screens, game over, etc.).

## Events
@export var game_over_event : Event
@export var neutral_ending_event : Event
@export var good_ending_event : Event
@export var bad_ending_event : Event

## Timings (seconds) — customize each ending's feel
@export_category("Timings - Game Over")
@export var go_fade_in_time := 5.0
@export var go_hold_time := 2.0
@export var go_fade_out_time := 3.0

@export_category("Timings - Good Ending")
@export var good_fade_in_time := 4.0
@export var good_hold_time := 2.0
@export var good_fade_out_time := 3.0

@export_category("Timings - Bad Ending")
@export var bad_fade_in_time := 3.0
@export var bad_hold_time := 1.5
@export var bad_fade_out_time := 2.0

@export_category("Timings - Neutral Ending")
@export var neutral_fade_in_time := 3.5
@export var neutral_hold_time := 2.0
@export var neutral_fade_out_time := 2.5

# Container
@onready var game_ending_screens: Control = $CanvasLayer/GameEndingScreens

# Good ending screen elements
@onready var good_ending_screen: Control = $CanvasLayer/GameEndingScreens/GoodEndingScreen
@onready var good_ending_screen_label: Label = %GoodEndingScreenLabel
@onready var good_ending_screen_button: Button = %GoodEndingScreenButton
@onready var good_ending_screen_background: ColorRect = $CanvasLayer/GameEndingScreens/GoodEndingScreen/GoodEndingScreenBackground
@onready var good_ending_overlay: ColorRect = $CanvasLayer/GameEndingScreens/GoodEndingScreen/GoodEndingOverlay

# Bad ending screen elements
@onready var bad_ending_screen: Control = $CanvasLayer/GameEndingScreens/BadEndingScreen
@onready var bad_ending_screen_label: Label = %BadEndingScreenLabel
@onready var bad_ending_screen_button: Button = %BadEndingScreenButton
@onready var bad_ending_screen_background: ColorRect = $CanvasLayer/GameEndingScreens/BadEndingScreen/BadEndingScreenBackground
@onready var bad_ending_overlay: ColorRect = $CanvasLayer/GameEndingScreens/BadEndingScreen/BadEndingOverlay

# Neutral ending screen elements
@onready var neutral_ending_screen: Control = $CanvasLayer/GameEndingScreens/NeutralEndingScreen
@onready var neutral_ending_label: Label = %NeutralEndingLabel
@onready var neutral_ending_button: Button = %NeutralEndingButton
@onready var neutral_ending_screen_background: ColorRect = $CanvasLayer/GameEndingScreens/NeutralEndingScreen/NeutralEndingScreenBackground
@onready var neutral_ending_overlay: ColorRect = $CanvasLayer/GameEndingScreens/NeutralEndingScreen/NeutralEndingOverlay

# Game over screen elements
@onready var game_over_ending_screen: Control = $CanvasLayer/GameEndingScreens/GameOverEndingScreen
@onready var game_over_label: Label = %GameOverLabel
@onready var game_over_button: Button = %GameOverButton
@onready var game_over_ending_screen_background: ColorRect = $CanvasLayer/GameEndingScreens/GameOverEndingScreen/GameOverEndingScreenBackground
@onready var game_over_overlay: ColorRect = $CanvasLayer/GameEndingScreens/GameOverEndingScreen/GameOverOverlay


var player : Player

const GAME_OVER_TEXT : Array[String] = [
	"ending_gameover_001",
	"ending_gameover_002",
	"ending_gameover_003"
]
const END_GAME_TEXT : Array[String] = [
	"ending_victory_001",
	"ending_victory_002",
	"ending_victory_003"
]


func _ready() -> void:
	neutral_ending_button.pressed.connect(go_back_to_menu)
	game_over_button.pressed.connect(load_from_savepoint)
	good_ending_screen_button.pressed.connect(go_back_to_menu)
	bad_ending_screen_button.pressed.connect(go_back_to_menu)
	
	EventManager.new_event_pushed.connect(_event_pushed)
	
	player = await PathfindingManager.get_player()
	
	game_ending_screens.hide()

	# Hide legacy single screens if they exist
	good_ending_screen.hide()
	bad_ending_screen.hide()
	neutral_ending_screen.hide()

	# Hide all backgrounds and overlays in the container
	_reset_all_endings_visibility()


func _event_pushed(event : Event) -> void:
	match event:
		game_over_event:
			await _show_game_over()
		neutral_ending_event:
			await _show_neutral()
		good_ending_event:
			await _show_good()
		bad_ending_event:
			await _show_bad()
		_:
			pass


# ---- Helpers ----

func _reset_all_endings_visibility() -> void:
	# Good
	good_ending_screen_background.hide()
	good_ending_overlay.hide()
	good_ending_overlay.modulate.a = 0.0
	# Bad
	bad_ending_screen_background.hide()
	bad_ending_overlay.hide()
	bad_ending_overlay.modulate.a = 0.0
	# Neutral
	neutral_ending_screen_background.hide()
	neutral_ending_overlay.hide()
	neutral_ending_overlay.modulate.a = 0.0
	# Game Over
	game_over_ending_screen_background.hide()
	game_over_overlay.hide()
	game_over_overlay.modulate.a = 0.0


func _hide_all_container_screens_except(node_to_show: Node = null) -> void:
	# Hide all backgrounds first
	good_ending_screen_background.hide()
	bad_ending_screen_background.hide()
	neutral_ending_screen_background.hide()
	game_over_ending_screen_background.hide()
	# Hide all overlays
	good_ending_overlay.hide()
	bad_ending_overlay.hide()
	neutral_ending_overlay.hide()
	game_over_overlay.hide()
	# Show only the parent screen container of the target background/overlay
	# (Assumes each background is a child of its respective <Ending>Screen under GameEndingScreens)
	if node_to_show == null:
		return
	for child in game_ending_screens.get_children():
		if child == node_to_show.get_parent():
			child.show()
		else:
			child.hide()


# Generic coroutine to run the overlay sequence
func _run_overlay_sequence(overlay: ColorRect, background: CanvasItem, fade_in: float, hold: float, fade_out: float) -> void:
	game_ending_screens.show()
	overlay.show()
	overlay.modulate.a = 0.0
	background.hide()

	await get_tree().process_frame

	var t := create_tween()
	t.tween_property(overlay, "modulate:a", 1.0, fade_in).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await t.finished

	await get_tree().create_timer(hold).timeout

	background.show()
	t = create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, fade_out).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await t.finished

	overlay.hide()
	# background remains visible for the menu (button, text, etc.)


# ---- Endings ----
func _show_good() -> void:
	player.player_state_machine.transition_to("PlayerParalize", {})
	_hide_all_container_screens_except(good_ending_screen_background)
	good_ending_screen_label.text = tr(END_GAME_TEXT.pick_random())
	await _run_overlay_sequence(good_ending_overlay, good_ending_screen_background, good_fade_in_time, good_hold_time, good_fade_out_time)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _show_bad() -> void:
	player.player_state_machine.transition_to("PlayerParalize", {})
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	_hide_all_container_screens_except(bad_ending_screen_background)
	bad_ending_screen_label.text = tr(END_GAME_TEXT.pick_random())
	await _run_overlay_sequence(bad_ending_overlay, bad_ending_screen_background, bad_fade_in_time, bad_hold_time, bad_fade_out_time)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _show_neutral() -> void:
	player.player_state_machine.transition_to("PlayerParalize", {})
	_hide_all_container_screens_except(neutral_ending_screen_background)
	neutral_ending_label.text = tr(END_GAME_TEXT.pick_random())
	await _run_overlay_sequence(neutral_ending_overlay, neutral_ending_screen_background, neutral_fade_in_time, neutral_hold_time, neutral_fade_out_time)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _show_game_over() -> void:
	player.player_state_machine.transition_to("PlayerParalize", {})
	_hide_all_container_screens_except(game_over_ending_screen_background)
	game_over_label.text = tr(GAME_OVER_TEXT.pick_random())
	await _run_overlay_sequence(game_over_overlay, game_over_ending_screen_background, go_fade_in_time, go_hold_time, go_fade_out_time)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func load_from_savepoint() -> void:
	SaveDataServer.load_control_point()
	_hide_all_container_screens_except()


func go_back_to_menu() -> void:
	SaveDataServer.saving = false
	SaveDataServer.create_fresh_save()
	good_ending_screen_button.disabled = true
	bad_ending_screen_button.disabled = true
	neutral_ending_button.disabled = true
	game_over_button.disabled = true
	
	var screen_flow_manager : ScreenFlowManager
	screen_flow_manager = get_tree().get_first_node_in_group("screen_flow_manager")
	screen_flow_manager.load_main_menu()
