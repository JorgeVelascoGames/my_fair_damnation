extends Node3D
class_name InteractableLight

## Used by the save system to differentiate between lights
@export var light_id : int
@export var start_lighted := false
@export var is_tweaking_light := false
@export var light_original_intensity := 1.0 ##The light energy of every single light on this switch
@export var position_lights: OmniLight3D 

#@onready var animation_player: AnimationPlayer = $Switch/PositionLights/AnimationPlayer
@onready var animation_tree: SwitchAnimation = $switch/AnimationTree
@onready var switch_audio: AudioStreamPlayer3D = $switch/SwitchAudio
@onready var forcing_audio: AudioStreamPlayer3D = $switch/ForcingAudio
@onready var interactable: Interactable = $switch/Interactable
@onready var shadows_container: Node3D = $ShadowsContainer

#const LIGHT_BUBBLE_SOUND = preload("res://Levels/environment_elements/light_bubble_sound.tscn")

var light_on := true
var lights_array : Array[Light3D] = []
var twinkling_ligt_tween : Tween
var shadows : Array[FrankShadow] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in shadows_container.get_children():
		if child is FrankShadow:
			shadows.append(child)
	for child in get_children(true):
		if child is Light3D:
			child.light_energy = light_original_intensity
			lights_array.append(child)
			#var sound = LIGHT_BUBBLE_SOUND.instantiate() as AudioStreamPlayer3D
			#child.add_child(sound)
	if not start_lighted:
		switch_light()
	if is_tweaking_light:
		twink_light()
	DayNightCycleController.day_started.connect(frank_shadows_control)
	DayNightCycleController.night_started.connect(frank_shadows_control)
	frank_shadows_control()


func on_switch_press() -> void:
	switch_light()
	
	#switch_audio.play()
	
	if light_on:
		pass #play sound TODO
		interactable.interaction_duration = 0.0
		interactable.interactable_hint = tr("turn_off")
	else:
		interactable.interaction_duration = 3.0
		interactable.interactable_hint = tr("hold_interact_lights")
		if twinkling_ligt_tween:
			twinkling_ligt_tween.kill()
	if light_on and is_tweaking_light:
		twink_light()
	
	frank_shadows_control()
	
	await get_tree().process_frame
	save_state()


func twink_light() -> void:
	for light in lights_array:
		twink_individual_light(light)


func twink_individual_light(light : Light3D) -> void:
	# Inicializamos la semilla de aleatoriedad
	randomize()
	while light_on:
		# Elegimos intervalos aleatorios para el 'apagado' y el 'encendido'
		var off_duration = randf_range(0.05, 0.2)
		var on_duration = randf_range(0.05, 0.3)
		
		# Creamos un Tween para "apagar" la luz gradualmente
		twinkling_ligt_tween = create_tween()
		twinkling_ligt_tween.tween_property(light, "light_energy", 0.0, off_duration)
		# Esperamos a que termine esta animación
		await twinkling_ligt_tween.finished
		#Con esto hacemos que pueda quedarse todo a oscuras un momento
		if randf() > 0.9:
			await get_tree().create_timer(randf_range(4.0, 6.0)).timeout
		
		# Si la luz se apaga durante el Tween, salimos del bucle
		if not light_on:
			break
		# Creamos otro Tween para "encender" la luz gradualmente
		twinkling_ligt_tween = create_tween()
		twinkling_ligt_tween.tween_property(light, "light_energy", light_original_intensity, on_duration)
		# Esperamos a que termine esta animación
		await twinkling_ligt_tween.finished
		if randf() > 0.6:
			await get_tree().create_timer(randf_range(0.5, 6.0)).timeout


func switch_light() -> void:
	light_on = !light_on
	for light in lights_array:
		light.visible = light_on
		light.light_energy = light_original_intensity
	position_lights.visible = !light_on 
	if light_on:
		animation_tree.switch_into_on_position()
	else:
		animation_tree.switch_into_off_position()


func _on_interactable_interacted() -> void:
	on_switch_press()
	forcing_audio.stop()


func _on_interactable_interrupt_interacting() -> void:
	animation_tree.switch_into_off_position()
	forcing_audio.stop()


func _on_interactable_start_interacting() -> void:
	animation_tree.start_moving_animation()
	forcing_audio.play()


func frank_shadows_control() -> void:
	for shadow in shadows:
		shadow.disable(false)
	if DayNightCycleController.current_period != DayNightCycleController.DAY:
		return
	if light_on:
		return
	var number_of_shadows = randi_range(1, shadows.size())
	for i in number_of_shadows:
		shadows[i].enable(true)


func save_state() -> void:
	SaveDataServer.save_lights(light_id, light_on)


func _load(data : SavedData) -> void:
	for shadow in shadows:
		shadow.disable(false)
	if not data.lights_state.keys().has(light_id):
		return
	if data.lights_state[light_id] == true:
		on_switch_press()
	await get_tree().create_timer(1).timeout #Para dar tiempo a que se cargue el periodo del dia
	frank_shadows_control()
