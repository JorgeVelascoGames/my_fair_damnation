extends Node

@export var events_to_achivements: Dictionary[Event, String] = {
}


func _ready():
	await get_tree().create_timer(0.1).timeout
	OS.set_environment("SteamAppID", str(AppManager.app_id))
	OS.set_environment("SteamGameID", str(AppManager.app_id))
	await get_tree().create_timer(0.1).timeout
	Steam.steamInit()

	var is_running := Steam.isSteamRunning()
	var id = Steam.getSteamID()
	var steam_name = Steam.getFriendPersonaName(id)
	if is_running:
		prints("Steam is running as: ", steam_name)
	else:
		prints("Steam is NOT running")

	EventManager.new_event_pushed.connect(_on_event_occurred)


func _on_event_occurred(event: Event) -> void:
	if events_to_achivements.keys().has(event):
		var achievement_id = events_to_achivements[event]
		if not Steam.getAchievement(achievement_id)["achieved"]:
			Steam.setAchievement(achievement_id)
			prints("Achievement unlocked: ", achievement_id)
		else:
			prints("Achievement already unlocked: ", achievement_id)
