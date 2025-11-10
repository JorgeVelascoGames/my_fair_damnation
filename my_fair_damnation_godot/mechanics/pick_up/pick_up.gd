extends Node3D
class_name PickUp

@export var item : Item


func pick_up() -> void:
	var player : Player = await PathfindingManager.get_player()
	player.player_inventory.give_item(item)
	await get_tree().process_frame
	queue_free()


func _on_interactable_interacted() -> void:
	pick_up()
