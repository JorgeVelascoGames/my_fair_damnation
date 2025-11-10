@tool
extends Node

# NpcVault is an autoload singleton that stores all Npc resources for save/load and lookups.

## Directory paths (relative to project root) where Npc resources are stored.
@export var npcs_folders_paths: Array[String] = []

## Array that holds all loaded Npc resources.
@export var all_npcs: Array[NpcId] = []

## Inspector button to refresh the npcs list from the folder.
@export_tool_button("Refresh Npcs", "Callable") var refresh_npcs_button := _load_all_npcs


func _entered_tree() -> void:
	if Engine.is_editor_hint():
		_load_all_npcs()


## Loads all `.tres` or `.res` files as Npc resources from the specified folder.
func _load_all_npcs() -> void:
	if not Engine.is_editor_hint():
		return
	all_npcs.clear()
	for npcs_folder_path in npcs_folders_paths:
		var dir = DirAccess.open(npcs_folder_path)
		if not dir:
			push_error("NpcVault: Could not open directory: %s" % npcs_folder_path)
			return
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".res")):
				var full_path = npcs_folder_path.path_join(file_name)
				var res = ResourceLoader.load(full_path)
				if res is NpcId:
					all_npcs.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("NpcVault: Loaded %d npcs from %s" % [all_npcs.size(), npcs_folder_path])
