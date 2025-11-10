extends Area3D
class_name EnemyHitbox

signal hitbox_damaged


func damage() -> void:
	hitbox_damaged.emit()
