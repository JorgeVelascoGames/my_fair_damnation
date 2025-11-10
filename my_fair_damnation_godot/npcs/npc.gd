extends Node3D
class_name Npc


@onready var npc_instance_controller: NpcInstanceController = $NpcInstanceController
@onready var npc_reputation: NpcReputation = $NpcReputation

## Unique id of this npc
@export var id : NpcId
@export var use_reputation := true


func _ready() -> void:
	if not NpcVault.all_npcs.has(id):
		NpcVault.all_npcs.append(id)


func get_shoot() -> void:
	pass


func on_event_pushed(event : Event) -> void:
	pass


func on_event_finished(event : Event) -> void:
	pass
