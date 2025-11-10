extends EnemyBehaviour
class_name IdleBehaviour

##This class creates the funcionality for enemies with idle type. Those enmies will stand still
##until provoked. Once they lose track of the player, they will return to stay idle in
##their former position or a new random position

var behaviour := EnemyBehaviourManager.behaviour_types.IDLE
var idle_spots : Array[Vector3] = []
var current_state : String


func activate_behaviour() -> void:
	for spot in get_children():
		if spot is Marker3D:
			idle_spots.append(spot.position)



func new_state_transitioned(state_name : String) -> void:
	if not active_behaviour:
		return
	if state_name == "EnemyIdle" and current_state == "EnemyChasing":
		await get_tree().create_timer(2).timeout
		return_to_idle_position()
	current_state = state_name


func return_to_idle_position() -> void:
	state_machine.transition_to("EnemyWalk", {"position" : idle_spots.pick_random()})
