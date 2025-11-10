extends EnemyBehaviour
class_name PatrolBehaviour

##This class creates the funcionality for enemies with patrol type. Those enmies will cycle
##a given set of points

##If this is true, the patrol waypoint array will be shuffled
@export var random_patrol := false

var behaviour := EnemyBehaviourManager.behaviour_types.PATROL
var patrol_spots : Array[Vector3] = []
var patrol_spots_duplicated : Array[Vector3]


func activate_behaviour() -> void:
	for spot in get_children():
		if spot is Marker3D:
			patrol_spots.append(spot.position)
	await get_tree().process_frame
	return_to_patrol()


func new_state_transitioned(state_name : String) -> void:
	if not active_behaviour:
		return
	
	if enemy_detection.is_player_tracked:
		return
	if state_name != "EnemyIdle":
		return
	await get_tree().create_timer(2).timeout
	if state_machine.get_state() == "EnemyIdle":
		return_to_patrol()


func return_to_patrol() -> void:
	if patrol_spots_duplicated.is_empty():
		patrol_spots_duplicated = patrol_spots.duplicate()
		if random_patrol:
			patrol_spots_duplicated.shuffle()
	
	state_machine.transition_to("EnemyWalk", {"position" : patrol_spots_duplicated.pop_front()})
