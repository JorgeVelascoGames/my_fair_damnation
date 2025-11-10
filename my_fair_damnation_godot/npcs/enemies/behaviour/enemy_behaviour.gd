extends Node3D
class_name EnemyBehaviour

@export var state_machine : StateMachine 
@export var enemy_detection: EnemyDetection 

var active_behaviour := false


func _ready() -> void:
	state_machine.transitioned.connect(new_state_transitioned)
	enemy_detection.found_player.connect(player_detected)


##Should be called by the enemy behaviour manager on ready
func activate_behaviour() -> void:
	pass


func new_state_transitioned(state_name : String) -> void:
	pass


func player_detected() -> void:
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if enemy_detection == null:
		warnings.append("Enemy detection needed")
	if state_machine == null:
		warnings.append("State machine needed")
	return warnings
