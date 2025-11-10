extends Node
class_name EnemyAnimatorController

@export var animation : AnimationPlayer

@export var idle_anim : String
@export var walk_anim : String
@export var chase_anim : String
@export var attack_anim : String
@export var stun_anim : String
@export var cooldown_anim : String
@export var dying_anim : String


func play_idle_animation() -> void:
	animation.play(idle_anim, .4)


func play_walk_animation() -> void:
	animation.play(walk_anim, .4)


func play_chase_animation() -> void:
	animation.play(chase_anim, .4)


func play_attack_animation() -> void:
	animation.play(attack_anim, .2)


func play_stun_animation() -> void:
	animation.play(stun_anim, .2)


func play_cooldown_animation() -> void:
	animation.play(cooldown_anim, .2)


func play_dying_animation() -> void:
	animation.play(dying_anim, .2)
