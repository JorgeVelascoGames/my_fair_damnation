extends PlayerComponent

class_name Madness

signal madness_increased
signal madness_decreased

## The max amount of madness
@export var max_madness := 1000.00
## The current level of madness. It must be between 0 and [member max_madness]
@export var current_madness := 0.0

## Tween animation time
@export var bar_animatino_time := 3.0
@export var game_over_event: Event

@onready var madness_bar: ProgressBar = %MadnessBar
@onready var madness_animation_player: AnimationPlayer = $MadnessAnimationPlayer

var madness_bar_tween: Tween


func _ready() -> void:
	madness_bar.max_value = max_madness
	madness_bar.value = current_madness
	madness_animation_player.animation_finished.connect(_on_madness_animation_player_animation_finished)
	#await get_tree().create_timer(2).timeout
	#substract_madness(100)


func _process(delta: float) -> void:
	if AppManager.godmode:
		current_madness = 0
	if current_madness >= max_madness:
		set_process(false)
		player_dies()


func add_madness(amount: float) -> void:
	if amount == 0:
		return
	current_madness = clamp(current_madness + amount, 0, max_madness)
	tween_madness_bar()
	save_madness()


func substract_madness(amount: float) -> void:
	if current_madness == 0:
		return ## So the madness bar doesnt animate when there is no change
	current_madness = clamp(current_madness - amount, 0, max_madness)
	tween_madness_bar()
	save_madness()


func add_madness_raw(amount: float) -> void:
	if amount == 0:
		return
	current_madness = clamp(current_madness + amount, 0, max_madness)
	madness_bar.value = current_madness
	save_madness()
	if not madness_animation_player.is_playing():
		madness_animation_player.play("show_madness_bar")


func substract_madness_raw(amount: float) -> void:
	if amount == 0:
		return
	current_madness = clamp(current_madness - amount, 0, max_madness)
	madness_bar.value = current_madness
	save_madness()
	if not madness_animation_player.is_playing():
		madness_animation_player.play("show_madness_bar")


func attacked() -> void:
	var remaining_madness := max_madness - current_madness
	var madness_gain := (remaining_madness * 0.12) + (max_madness * 0.03) + 20
	player.player_audio.hit_scream()
	add_madness(madness_gain)


func tween_madness_bar() -> void:
	if not madness_animation_player.is_playing():
		madness_animation_player.play("show_madness_bar")
	if madness_bar_tween:
		madness_bar_tween.kill()
	madness_bar_tween = create_tween()
	madness_bar_tween.tween_property(madness_bar, "value", current_madness, bar_animatino_time)


func player_dies() -> void:
	EventManager.push_new_event(game_over_event)


func _on_madness_animation_player_animation_finished(anim_name: StringName) -> void:
	if madness_bar_tween and madness_bar_tween.is_running():
		madness_animation_player.play("show_madness_bar")


func on_day_start() -> void:
	player.madness.substract_madness(150)


func on_night_start() -> void:
	player.madness.substract_madness(50)


func on_sleep_all_night() -> void:
	player.madness.substract_madness(50)


func save_madness() -> void:
	SaveDataServer.save_madness(current_madness)


func _load(data: SavedData) -> void:
	current_madness = data.player_madness
	madness_bar.value = current_madness
