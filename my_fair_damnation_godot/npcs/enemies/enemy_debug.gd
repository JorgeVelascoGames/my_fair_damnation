extends Node3D

## If ture, the enemy current state will be displayed in a 3D label over its head
@export var debug_enemy := false

@onready var state_machine: StateMachine = %StateMachine
@onready var state_label: Label3D = $StateLabel


func _ready() -> void:
	if not debug_enemy:
		hide()


func _process(delta: float) -> void:
	if not debug_enemy:
		return
	state_label.text = state_machine.get_state()
	
