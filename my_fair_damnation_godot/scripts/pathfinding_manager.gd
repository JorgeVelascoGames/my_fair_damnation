extends Node

var player : Player 
var player_position: Vector3


func set_up_player(current_player: Player) -> void:
	player = current_player


func _on_timer_timeout() -> void:
	if player:
		player_position = player.global_position


##This should be on another script...#TODO
func get_player() -> Player:
	while not is_instance_valid(player):
		await get_tree().process_frame
	
	return player
