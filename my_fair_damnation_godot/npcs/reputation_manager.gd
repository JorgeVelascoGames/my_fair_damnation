extends Node
## This manages the variation of reputation on the game

signal reputation_with_player_changes(NpcId, float)

enum reputation_level{
	HOSTILE,
	NEUTRAL,
	POSITIVE
}

const HOSTILE := reputation_level.HOSTILE
const NEUTRAL := reputation_level.NEUTRAL
const POSITIVE := reputation_level.POSITIVE

## The ratio which social changes with the player propagate to other npcs. This is multiplied by the total amount
## of original reputation variation. I.E, if an npc losses 15 reputation with the player, other
## npc's with [member POSITIVE] relatioship with this npc will also lose 15 * [member social_propagatin_ratio]
## So the higher the number, the more sensible npcs are to player actions
var social_propagation_ratio := 0.5


func propagate_social_consecuences_with_player(user_id: NpcId, amount : float) -> void:
	reputation_with_player_changes.emit(user_id, amount * social_propagation_ratio)


## Returns the enumerator value corresponding to a reputation level. It should be used to
## determen the social position of an npc towards another or the player given its reputation level in number
func get_reputation_level(amount : float) -> reputation_level:
	if amount < 0:
		return HOSTILE
	elif amount > 100:
		return POSITIVE
	else:
		return NEUTRAL
