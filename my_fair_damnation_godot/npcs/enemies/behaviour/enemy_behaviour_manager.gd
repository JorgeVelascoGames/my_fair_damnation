extends EnemyComponent
class_name EnemyBehaviourManager

## This node dictates how the enemy behaves in the world.

enum behaviour_types {
	IDLE,
	PATROL,
	ROAM,
	STALK,
	UNRELENTING_CHASE,
}

const IDLE := behaviour_types.IDLE
const PATROL := behaviour_types.PATROL
const ROAM := behaviour_types.ROAM
const STALK := behaviour_types.STALK
const UNRELENTING_CHASE := behaviour_types.UNRELENTING_CHASE


@export var enemy_behaviour : EnemyBehaviour


func _ready() -> void:
	enemy_behaviour.active_behaviour = true
	enemy_behaviour.activate_behaviour()
