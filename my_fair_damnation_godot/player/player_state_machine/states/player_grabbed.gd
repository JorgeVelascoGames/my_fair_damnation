extends PlayerState
class_name PlayerGrabbed

var target_look_at

## The amount of zoom during the attack
@export var camera_zoom_pov := 37.80

@onready var world_camera: SmoothCamera = $"../../CameraPivot/WorldCamera"

var original_zoom_pov : float
var tween: Tween


func enter(_msg : ={}) -> void:
	player.madness.attacked()
	player.velocity = Vector3.ZERO
	target_look_at = _msg["position"]
	if tween:
		tween.kill()
	original_zoom_pov = world_camera.fov
	tween = create_tween()
	tween.tween_property(world_camera, "fov", camera_zoom_pov, .3)


func update(delta) -> void:
	player.camera_pivot.look_at(target_look_at.global_position)
	var body_position = target_look_at.global_position
	body_position.y = player.global_position.y
	player.look_at(body_position)


func exit() -> void:
	player.rotation.x = 0
	player.rotation.z = 0
	player.camera_pivot.rotation.y = 0
	player.camera_pivot.rotation.z = 0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(world_camera, "fov", original_zoom_pov, .3)
