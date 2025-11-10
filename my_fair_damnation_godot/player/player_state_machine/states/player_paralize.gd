extends PlayerState
class_name PlayerParalize


func enter(_msg : ={}) -> void:
	player.velocity = Vector3.ZERO


func physics_update(delta: float) -> void:
	player.move_and_slide() # To process gravity
