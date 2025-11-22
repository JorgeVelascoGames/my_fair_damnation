extends CharacterBody3D
class_name Enemy

@export var enemy_model : Node3D
@export var look_at_player : LookAtModifier3D

@onready var player : Player = await PathfindingManager.get_player()
@onready var enemy_navigation: EnemyNavigation = $EnemyNavigation
@onready var enemy_detection: EnemyDetection = $EnemyDetection
@onready var state_machine: StateMachine = %StateMachine
@onready var enemy_audio: EnemyAudio = $EnemyAudio

var original_pos : Vector3


func _ready() -> void:
	apply_floor_snap()
	look_at_player.target_node = player.camera_pivot.get_path()
	for node in get_children(true):
		if node is EnemyComponent:
			node.set_up_component(player, self)
	original_pos = global_position


func _process(delta: float) -> void:
	if enemy_model:
		enemy_model.position = Vector3.ZERO


func orient_character(target_position: Vector3, delta: float) -> void:
	# Igualamos altura para evitar inclinaciones
	target_position.y = global_position.y
	
	# Dirección al objetivo
	var direction = (target_position - global_position).normalized()
	if direction.length() == 0:
		return
	
	# Ángulo actual y deseado en Y
	var current_yaw = rotation.y
	var target_yaw = atan2(-direction.x, -direction.z)
	
	# Interpolamos hacia el target con rapidez
	var speed := 10.0  # Puedes ajustar este valor según lo rápido que quieres que gire
	var new_yaw = lerp_angle(current_yaw, target_yaw, speed * delta)
	
	# Aplicamos la rotación suavizada
	global_rotation.y = new_yaw


func look_at_y_axis_only(target_position: Vector3) -> void:
	var direction = target_position - global_transform.origin
	direction.y = 0  # Ignorar altura, solo queremos rotación en plano XZ

	if direction.length_squared() == 0:
		return  # Ya estamos en la posición objetivo o muy cerca

	direction = direction.normalized()
	var target_rotation = atan2(-direction.x, -direction.z)
	rotation.y = target_rotation


func _activate_instance() -> void:
	global_position = original_pos
	enemy_model.show()
	state_machine.process_mode = Node.PROCESS_MODE_INHERIT
	enemy_navigation.process_mode = Node.PROCESS_MODE_INHERIT
	enemy_detection.process_mode = Node.PROCESS_MODE_INHERIT


func disable_instance() -> void:
	enemy_audio.shut_down_audio()
	global_position = original_pos
	enemy_model.hide()
	state_machine.process_mode = Node.PROCESS_MODE_DISABLED
	enemy_navigation.process_mode = Node.PROCESS_MODE_DISABLED
	enemy_detection.process_mode = Node.PROCESS_MODE_DISABLED
