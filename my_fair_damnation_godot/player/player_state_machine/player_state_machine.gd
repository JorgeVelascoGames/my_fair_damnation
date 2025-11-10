extends StateMachine
class_name PlayerStateMachine

@export var debug_state_name := false
@export var state_label: Label 


func _ready() -> void:
	super()
	
	if debug_state_name:
		state_label.show()
	else:
		state_label.hide()


func _unhandled_input(event):
	state._handle_input(event)


func transition_to(target_state_name : String, msg : Dictionary) -> void:
	super(target_state_name, msg)
	state_label.text = state.name
