extends Camera3D
class_name SmoothCamera

@export var speed := 60.0
@export var gun_following_speed := 1.0
@export var gun : Node3D


func _physics_process(delta):
	smooth_gun(delta)
	var weight :float = clamp(delta * speed, 0.0, 0.5) 
	
	global_transform = global_transform.interpolate_with(
		get_parent().global_transform, weight
	)
	global_position = get_parent().global_position


##Smooth the camera used to render equiped items
func smooth_gun(delta: float) -> void:
	# Calcula un 'peso' de interpolación en base al delta y a la velocidad que desees
	var weight = clamp(delta * gun_following_speed, 0.0, 1.0)
	
	# Interpola la posición (y rotación, y escala) de la gun
	# para que se acerque al global_transform del nodo que tiene este script
	gun.global_transform = gun.global_transform.interpolate_with(
		global_transform,
		weight
	)
	gun.global_rotation = get_parent().global_rotation
