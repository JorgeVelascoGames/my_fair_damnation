extends NpcComponent
class_name NpcReputation

@export var reputation_with_other_npcs : Dictionary[NpcId, float] = {}
@export var reputation_with_player : float
@export var reputation_change_message : Dictionary[ReputationManager.reputation_level, String] = {}

var player_ui : PlayerUI

func _ready() -> void:
	ReputationManager.reputation_with_player_changes.connect(social_consecuences_propagation)


## Called when the reputation changes with another npc or with the player. If the NpcId is null,
## it will change reputation with the player
func reputation_change(amount : float, id : NpcId = null) -> void:
	if id == null:
		var level = ReputationManager.get_reputation_level(reputation_with_player)
		reputation_with_player += amount
		var new_level = ReputationManager.get_reputation_level(reputation_with_player)
		if level != new_level:
			player_message_reputation_change()
		#ReputationManager.propagate_social_consecuences_with_player(npc.id, amount)
	else:
		if not reputation_with_other_npcs.has(id):
			reputation_with_other_npcs[id] = 0.0 # In case the npc id is not on the dicctionary, now it is
		reputation_with_other_npcs[id] += amount


##DEPRECATED This is a discarted mechanic
func social_consecuences_propagation(id : NpcId, amount : float) -> void:
	var reputation_state = ReputationManager.get_reputation_level(reputation_with_other_npcs[id])
	if reputation_state == ReputationManager.HOSTILE: # If I hate him...
		if amount < 0: # ...and the player messes with him...
			reputation_with_player += abs(amount) # ...now I like the player better
		if amount > 0: # ...and the player helps him...
			reputation_with_player -= amount # ... now I like the player less
	if reputation_state == ReputationManager.POSITIVE: # If I like him...
		reputation_with_player += amount # ...whatever the player does to him, I'll feel the same


func get_reputation_towards_player() -> ReputationManager.reputation_level:
	return ReputationManager.get_reputation_level(reputation_with_player)


func save_reputation() -> void:
	var temp : Dictionary[String, float]
	for npc_id : NpcId in reputation_with_other_npcs.keys():
		temp[npc_id.npc_name] = reputation_with_other_npcs[npc_id]
	
	SaveDataServer.save_npc_reputation(npc.id, reputation_with_player, temp)


func _load(data : SavedData) -> void:
	#If there is no data, create the key value pair:
	if data.reputation_with_player.keys().has(npc.id.npc_name):
		reputation_with_player = data.reputation_with_player[npc.id.npc_name]
	
	if data.reputation_between_npcs.keys().has(npc.id.npc_name):
		for npc_name in data.reputation_between_npcs[npc.id.npc_name].keys():
			reputation_with_other_npcs[get_NpcId_with_string(npc_name)] = data.reputation_between_npcs[npc.id.npc_name][npc_name]


func player_message_reputation_change() -> void:
	player_ui = await PathfindingManager.get_player().player_ui
	var rep_level = ReputationManager.get_reputation_level(reputation_with_player) 
	player_ui.display_gameplay_text(tr(reputation_change_message[rep_level])) 


func get_npc_reputations_with_string_keys() -> Dictionary[String, float]:
	var temp : Dictionary[String, float]
	
	return temp


func get_NpcId_with_string(name : String) -> NpcId:
	for npc in NpcVault.all_npcs:
		if npc.id.npc_name == name:
			return npc.id
	return null
