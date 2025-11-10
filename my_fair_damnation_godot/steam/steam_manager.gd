extends Node

## Your Steam AppID (for testing, use 480; for release, tu AppID real)
var app_id: int = 480

## Tracks unlocked achievements to avoid re-enabling
var unlocked_achievements: Dictionary = {}


func _ready() -> void:
	# Auto-init via Project Settings es opcional; también se puede hacer manualmente:
	var init_result = Steam.steamInitEx(app_id, true)
	print("Steam initialized:", init_result)
	
	# Conectar señales de estadísticas/logros
	Steam.user_stats_received.connect(_on_user_stats_received)
	Steam.user_stats_stored.connect(_on_user_stats_stored)


func _process(delta: float) -> void:
	# Procesa los callbacks del API Steam
	Steam.run_callbacks()


## Recibe los stats del usuario
func _on_user_stats_received(game_id: int, result: int, user_id: int) -> void:
	print("Stats received:", game_id, "result:", result, "user:", user_id)


## Callback tras almacenar stats/logros
func _on_user_stats_stored(game_id: int, success: bool) -> void:
	print("Stats stored for", game_id, ":", success)


## Unlock a specific achievement by its internal Steam name
func unlock_achievement(ach_name: String) -> void:
	if unlocked_achievements.has(ach_name) and unlocked_achievements[ach_name]:
		return
	if Steam.setAchievement(ach_name):
		unlocked_achievements[ach_name] = true
		var stored = Steam.storeStats()
		print("Achievement", ach_name, "unlocked, stored:", stored)


## Check if an achievement is already unlocked locally
func has_achievement(ach_name: String) -> bool:
	return unlocked_achievements.get(ach_name, false)
