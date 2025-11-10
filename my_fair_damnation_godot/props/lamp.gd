extends Node3D
class_name Lamp

@onready var spot_light_3d: SpotLight3D = $SpotLight3D
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var twinkle_light_timer: Timer = $TwinkleLightTimer
@onready var twinkle_cooldown_timer: Timer = $TwinkleCooldownTimer

var original_spot_energy: float
var original_omni_energy: float
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	original_spot_energy = spot_light_3d.light_energy
	original_omni_energy = omni_light_3d.light_energy
	rng.randomize()
	twinkle_cooldown_timer.timeout.connect(_on_twinkle_cooldown_timer_timeout)
	_start_twinkle_cooldown()


func _start_twinkle_cooldown() -> void:
	# Espera entre 4 y 12 segundos para el siguiente parpadeo
	var wait_time := rng.randf_range(4.0, 12.0)
	twinkle_cooldown_timer.wait_time = wait_time
	twinkle_cooldown_timer.start()


func _on_twinkle_cooldown_timer_timeout() -> void:
	# Inicia el parpadeo
	_start_twinkle()


func _start_twinkle() -> void:
	# Elegimos un tipo de parpadeo aleatorio
	var flicker_type := rng.randi_range(0, 2)

	match flicker_type:
		0:
			await _flicker_once()
		1:
			await _flicker_dim()
		2:
			await _flicker_off_and_on()

	# Reiniciar el cooldown para el próximo parpadeo
	_start_twinkle_cooldown()


func _flicker_once() -> void:
	var tween := create_tween()
	tween.tween_property(spot_light_3d, "light_energy", original_spot_energy * 0.2, 0.05)
	tween.parallel().tween_property(omni_light_3d, "light_energy", original_omni_energy * 0.2, 0.05)
	await tween.finished

	await get_tree().create_timer(0.1).timeout

	var tween2 := create_tween()
	tween2.tween_property(spot_light_3d, "light_energy", original_spot_energy, 0.1)
	tween2.parallel().tween_property(omni_light_3d, "light_energy", original_omni_energy, 0.1)
	await tween2.finished


func _flicker_dim() -> void:
	# Baja lentamente y vuelve a subir con algo de titileo
	var tween := create_tween()
	tween.tween_property(spot_light_3d, "light_energy", original_spot_energy * 0.4, 0.3)
	tween.parallel().tween_property(omni_light_3d, "light_energy", original_omni_energy * 0.4, 0.3)
	await tween.finished

	await get_tree().create_timer(0.1).timeout

	var tween2 := create_tween()
	tween2.tween_property(spot_light_3d, "light_energy", original_spot_energy * 0.6, 0.1)
	tween2.parallel().tween_property(omni_light_3d, "light_energy", original_omni_energy * 0.6, 0.1)
	await tween2.finished

	var tween3 := create_tween()
	tween3.tween_property(spot_light_3d, "light_energy", original_spot_energy, 0.1)
	tween3.parallel().tween_property(omni_light_3d, "light_energy", original_omni_energy, 0.1)
	await tween3.finished


func _flicker_off_and_on() -> void:
	# Se apaga por completo brevemente y luego vuelve
	var tween := create_tween()
	tween.tween_property(spot_light_3d, "light_energy", 0.0, 0.2)
	tween.parallel().tween_property(omni_light_3d, "light_energy", 0.0, 0.2)
	await tween.finished

	await get_tree().create_timer(rng.randf_range(0.2, 0.5)).timeout

	var tween2 := create_tween()
	tween2.tween_property(spot_light_3d, "light_energy", original_spot_energy, 0.4)
	tween2.parallel().tween_property(omni_light_3d, "light_energy", original_omni_energy, 0.4)
	await tween2.finished
