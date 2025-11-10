extends PlayerState
class_name PlayerPrepareGun

@onready var camera_pivot: Node3D = %CameraPivot
@onready var gun_model: Node3D = $"../../PlayerUI/ItemDisplayer/SubViewport/ItemCamera/AnimatedCameraObjects/GunModel"
@onready var animated_objects_animations: AnimationPlayer = $"../../PlayerUI/ItemDisplayer/SubViewport/ItemCamera/AnimatedCameraObjects/AnimatedObjectsAnimations"

var tween : Tween


func enter(_msg : ={}) -> void:
	gun_model.show()
	animated_objects_animations.play("prepare_gun")
	player.player_audio.load_gun()
	animated_objects_animations.animation_finished.connect(_on_animation_finished)
	player.velocity = Vector3.ZERO
	tween = create_tween()
	var target_rotation = Vector3(-60, 0, 0) * deg_to_rad(1)
	tween.tween_property(camera_pivot, "rotation", target_rotation, 0.45)


func update(_delta) -> void:
	if Input.is_action_just_released("aim"):
		state_machine.transition_to("PlayerIdle", {})


func _on_animation_finished(anim_name : String) -> void:
	player.player_audio.load_gun()
	state_machine.transition_to("PlayerAiming", {})


func exit() -> void:
	animated_objects_animations.animation_finished.disconnect(_on_animation_finished)
	if tween:
		tween.kill()
	gun_model.hide()
	animated_objects_animations.play("RESET")
