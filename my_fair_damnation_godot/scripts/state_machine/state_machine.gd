extends Node

class_name StateMachine

signal transitioned(state_name)

@export var enabled := true
@export var initial_state := NodePath()
@onready var state: State = get_node(initial_state)


func _ready():
	await owner.ready

	for child in get_children():
		if child is State:
			child.state_machine = self
	state.enter()


func _process(delta):
	if not enabled:
		return
	state.update(delta)


func _physics_process(delta):
	if not enabled:
		return
	state.physics_update(delta)


func transition_to(target_state_name: String, msg: Dictionary):
	if not enabled:
		return
	if not has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	print("Transitioned to state: ", state.name)
	emit_signal("transitioned", state.name)


func get_state():
	return state.name as String
