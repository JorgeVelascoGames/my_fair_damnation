extends State
class_name EnemyState


var enemy : Enemy

@onready var enemy_animator_controller: EnemyAnimatorController = $"../../EnemyAnimatorController"


func _ready():
	await owner.ready
	enemy = owner as Enemy
	
	assert(enemy != null, "Invalid state node")
