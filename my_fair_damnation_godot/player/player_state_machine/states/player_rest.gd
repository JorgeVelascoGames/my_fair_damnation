extends PlayerState
class_name PlayerRest

@export var resting_time := 3.0


func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO
	var color_rect : ColorRect = player.player_ui.player_black_screen
	# Asegurarse de que empieza invisible
	color_rect.modulate.a = 0.0
	color_rect.visible = true

	# Fade IN (alpha de 0 a 1 en 0.8s)
	var tween_in := create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 1.0, 0.8)
	await tween_in.finished

	# Esperar tiempo de descanso
	await get_tree().create_timer(resting_time).timeout

	# Fade OUT (alpha de 1 a 0 en 0.8s)
	var tween_out := create_tween()
	tween_out.tween_property(color_rect, "modulate:a", 0.0, 0.8)
	if DayNightCycleController.current_period == DayNightCycleController.DAY:
		player.player_ui.display_gameplay_text("%s %d" % [tr("morning_of"), DayNightCycleController.day_count])
	await tween_out.finished
	color_rect.visible = false

	state_machine.transition_to("PlayerIdle", {})


func physics_update(delta: float) -> void:
	player.move_and_slide() # To process gravity


func exit() -> void:
	SaveDataServer.save_game()
