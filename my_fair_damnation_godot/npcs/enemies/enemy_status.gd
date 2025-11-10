extends EnemyComponent
class_name EnemyStatus

signal posture_broken

@export var max_health : int

@onready var state_machine: StateMachine = %StateMachine

var current_health : int


func _ready() -> void:
	current_health = max_health


func damage() -> void:
	%EnemyDetection.player_found()
	#current_health -= 1
	#if current_health <= 0:
		#die()
		#return
	state_machine.transition_to("EnemyStuned", {})
	enemy.enemy_audio.play_stun()


func die() -> void:
	pass


func _on_enemy_hitbox_hitbox_damaged() -> void:
	damage()
