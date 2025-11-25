extends Node3D
class_name FrankShadow

const ANIMATIONS : Array[String] = [
	"Idle_2",
	"stun",
	"chase",
	"chuch_idle"
]

@export var rotates := true

@onready var look_at_modifier_3d: LookAtModifier3D = $Model/FrankModel/Armature/Skeleton3D/LookAtModifier3D
@onready var look_at_marker_3d: Marker3D = $Model/FrankModel/Armature/Skeleton3D/BoneAttachment3D/LookAtMarker3D
@onready var player_catcher: PlayerCatcher = $PlayerCatcher
@onready var mr_frank: MeshInstance3D = $"Model/FrankModel/Armature/Skeleton3D/Mr Frank"
@onready var disabled_timer: Timer = $DisabledTimer
@onready var model: Node3D = $Model
@onready var animation_player: AnimationPlayer = $Model/FrankModel/AnimationPlayer
@onready var visible_on_screen_notifier_3d: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

var player : Player
var mat : StandardMaterial3D


func _ready() -> void:
	mat = mr_frank.material_override.duplicate(true)
	mr_frank.material_override = mat #Para que no pase eso de que todos compartan material y se disuelvan a la vez
	await get_tree().create_timer(3).timeout
	player = await PathfindingManager.get_player()
	look_at_modifier_3d.target_node = player.player_head_area.get_path()


func _on_player_catcher_player_detected() -> void:
	if player == null:
		return
	player.player_state_machine.transition_to("PlayerGrabbed", {"position" : look_at_marker_3d})
	await get_tree().process_frame
	player_catcher.monitoring = false
	await get_tree().create_timer(3).timeout
	player.player_state_machine.transition_to("PlayerIdle", {})
	fade_out()


func _process(delta: float) -> void:
	if not rotates:
		return
	if not visible_on_screen_notifier_3d.is_on_screen() and is_instance_valid(player):
		var direction := (player.global_transform.origin - global_transform.origin).normalized()
		direction.y = 0  # Ignorar altura
		if direction.length_squared() > 0:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, delta * 3.0)  # suavizado


func fade_out() -> void:
	var start_color := mat.albedo_color
	var end_color := start_color
	end_color.a = 0.0

	var tween := create_tween()
	tween.tween_property(mat, "albedo_color", end_color, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	disable(30)


func enable(force := false) -> bool:
	if not disabled_timer.is_stopped() and not force:
		return false
	animation_player.play(ANIMATIONS.pick_random())
	player_catcher.monitoring = true
	model.show()
	return true


func disable(timer := 1.0, start_timer := true) -> void:
	if start_timer:
		disabled_timer.start(timer)
	player_catcher.monitoring = false
	model.hide()
