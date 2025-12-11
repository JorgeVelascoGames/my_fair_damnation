extends Node

var is_demo := false
var godmode := false

var use_head_bob := true
var default_volume := 65.00
var volume := 65.00
var store_link := "https://store.steampowered.com/app/2881170/My_fair_damnation/?beta=0"
var app_id := 2881170
var discord_link := "https://discord.gg/ngvHvhWx"

var game_match_running := false

const SHOW_ALL_DIALOGS_CHEAT := preload("uid://d0e832gnlqgg6")


func load_settings(data: SavedData) -> void:
	volume = data.volume
	use_head_bob = data.use_head_bob
