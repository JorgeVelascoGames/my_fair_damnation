extends AnimationTree
class_name SwitchAnimation

@onready var animations = self["parameters/playback"]


func start_moving_animation() -> void:
	animations.travel("Moving")


func switch_into_off_position() -> void:
	animations.travel("deactivating")


func switch_into_on_position() -> void:
	animations.travel("activating")
