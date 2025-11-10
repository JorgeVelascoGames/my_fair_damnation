extends EnemyComponent
class_name EnemyDetection

##Emmited every frame while the enemy has line of sight of the player's head
signal found_player
##Emmited when the player gets off the enemy line of sight long enought
signal lose_player_track
##When the player collider overlaps with the hurtbox
signal player_entered_attack_range

@export var audio_detection_range : float = 5
@export var time_to_lose_track := 5.0

@onready var vision_detection_area: Area3D = $Vision/VisionDetectionArea
@onready var line_of_sight: RayCast3D = $Vision/LineOfSight
@onready var lose_track_timer: Timer = $LoseTrackTimer
@onready var visible_on_screen_notifier_3d: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var player_vision_checker: RayCast3D = $VisibleOnScreenNotifier3D/PlayerVisionChecker

var is_player_on_sight := false
var is_player_tracked := false
var is_detecting := true


func _process(delta: float) -> void:
	detect_player_on_sight()


func start_detection() -> void:
	is_detecting = true
	set_process(true)


func stop_detection() -> void:
	is_detecting = false
	set_process(false)


func detect_player_on_sight() -> void:
	if vision_detection_area.overlaps_body(player):
		line_of_sight.look_at(player.global_position)
		if line_of_sight.is_colliding() and line_of_sight.get_collider() is Player:
				player_found()
				is_player_on_sight = true
		else:
			player_lose()
			is_player_on_sight = false
	else:
		player_lose()
		is_player_on_sight = false


##Returns true if the player has direct line of sight with the enemy
func does_player_sees() -> bool:
	if visible_on_screen_notifier_3d.is_on_screen():
		player_vision_checker.look_at(player.global_position)
		if player_vision_checker.is_colliding() and player_vision_checker.get_collider() is Player:
			return true
	return false


func player_found() -> void:
	lose_track_timer.stop()
	found_player.emit()
	is_player_tracked = true


##When the player stops being detected, this method will run a timer to 
##determine if the chase is over. The enemy will still follow the player until the timer goes off.
##Getting line of sight of the player will, of course, stope the timer
func player_lose() -> void:
	if is_player_tracked and lose_track_timer.is_stopped():
		lose_track_timer.start(time_to_lose_track)


##Forces the enemy to lose track of the player
func force_lose_player() -> void:
	is_player_tracked = false
	lose_player_track.emit()


func _on_lose_track_timer_timeout() -> void:
	force_lose_player()


func _on_attack_range_body_entered(body: Node3D) -> void:
	print("Attack area detected %s by %s" % [body.name, enemy.name])
	player_entered_attack_range.emit()


func _on_enemy_automatic_detection_body_entered(body: Node3D) -> void:
	player_found()


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	pass # Replace with function body.
