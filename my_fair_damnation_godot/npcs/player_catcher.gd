extends Area3D
class_name PlayerCatcher

##Used to detect the player in an area

signal player_detected

##Optional interactable to trigger when detecting player
@export var interactable : Interactable
@export var one_use_only := false

var looking_for_player := true


func _ready() -> void:
	monitorable = false
	monitoring = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(4, true)
	set_collision_mask_value(1, false)
	body_entered.connect(body_detected)


func body_detected(body) -> void:
	if not looking_for_player:
		return
	if body is not Player:
		return
	if one_use_only:
		looking_for_player = false
	player_detected.emit()
	if interactable:
		interactable.interact()
