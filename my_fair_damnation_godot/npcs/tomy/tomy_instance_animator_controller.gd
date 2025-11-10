extends NpcInstanceAnimator

@export var first_encounter : Event
@export var trust_position : Vector3
@export var trust_rotation : Vector3
@export var distrust_position : Vector3
@export var distrust_rotation : Vector3
@onready var player_catcher: PlayerCatcher = $"../Interactable/PlayerCatcher"
@onready var main_instance: NpcInstance = $".."


func _ready() -> void:
	player_catcher.player_detected.connect(player_detected)


func select_animation() -> void:
	if not EventManager.current_events.has(first_encounter):
		animation_player.play("tommy_jumpscare_preparing")
		return
	player_catcher.monitoring = false
	if npc.npc_reputation.get_reputation_towards_player() == ReputationManager.POSITIVE:
		main_instance.position = trust_position
		main_instance.rotation = trust_rotation
		animation_player.play("tommy_idle")
	else:
		main_instance.position = distrust_position
		main_instance.rotation = distrust_rotation
		animation_player.play("tommy_jumpscare_idle")


func player_detected() -> void:
	animation_player.play("tommy_jumpscare")
	await animation_player.animation_finished
	animation_player.play("tommy_jumpscare_idle")
