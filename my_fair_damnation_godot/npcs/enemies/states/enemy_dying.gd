extends EnemyState
class_name EnemyDying

@export var mesh : MeshInstance3D


func enter(_msg = {}) -> void:
	state_machine.enabled = false
	enemy_animator_controller.play_dying_animation()
	enemy.enemy_navigation.stop()
	var tween = create_tween()
	# Se realiza el tween para cambiar la propiedad 'material_override.albedo_color' a Color rojo en 3 segundos.
	tween.tween_property(
		mesh.get_surface_override_material(0), 
		"albedo_color", 
		Color(1, 0, 0, 0), 
		2.0
	)
	await tween.finished
	owner.queue_free()
