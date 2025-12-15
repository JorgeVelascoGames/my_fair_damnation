extends Resource

class_name SavedData

##The save file for the player's progress. It's created when the game if there is none
##This sotores de progress of the player in the overall progress

# If the field has been saved at least one
@export var file_virgin := true
# If it's a checkpoint
@export var loaded_from_checkpoint := false
# Events
@export var current_evets: Array[String]
@export var passed_events: Array[String]
@export var one_day_lasting_events: Array[String]
# Player
@export var inventory: Array[String]
@export var player_position: Vector3
@export var player_rotation: Vector3
@export var player_madness: float
@export var stamina: float
@export var exhaustion_message_shown := false
@export var player_area: String
# Dialogs
@export var consumed_dialogs: Array[String]
@export var seen_dialogs: Array[String]
@export var once_per_day_dialogs: Array[String]
# Reputation
@export var reputation_with_player: Dictionary[String, float] = { }
@export var reputation_between_npcs: Dictionary[String, Dictionary] = { }
# Scenario
@export var lights_state: Dictionary[int, bool] = { }
# Day night cycle
@export var day_count: int
@export var day_night_period: int
@export var time_remaining: float
@export var environment: int #This is neccesary because on DOOM, both environments could be use
# Localization
@export var lenguage := "en"
# Npcs
@export var npcs_current_instance: Dictionary[String, int] = { }
# Object destructors
@export var descturctors_ids: Array[int]
# Saved characters
@export var npcs_saved: Dictionary[String, bool] = { }
# Filling cabinets
@export var filling_cabinets: Dictionary[int, bool] = { }
# Message displayers
@export var message_displayers: Dictionary[int, bool] = { }
# Settings
@export var volume := 75.00
@export var use_head_bob := true
@export var camera_sensibility := 1.2
@export var invert_mouse := false
# In game sound
@export var day_music_playback_position := 0.0
