@tool
extends Node

# ItemVault is an autoload singleton that stores all Item resources for save/load and lookups.

## Directory paths (relative to project root) where Item resources are stored.
@export var items_folders_paths: Array[String] = []

## Array that holds all loaded Item resources.
@export var all_items: Array[Item] = []

## Inspector button to refresh the items list from the folder.
@export_tool_button("Refresh Items", "Callable") var refresh_items_button := _load_all_items


func _entered_tree() -> void:
	if Engine.is_editor_hint():
		_load_all_items()


## Loads all `.tres` or `.res` files as Item resources from the specified folder.
func _load_all_items() -> void:
	if not Engine.is_editor_hint():
		return
	all_items.clear()
	for items_folder_path in items_folders_paths:
		var dir = DirAccess.open(items_folder_path)
		if not dir:
			push_error("ItemVault: Could not open directory: %s" % items_folder_path)
			return
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".res")):
				var full_path = items_folder_path.path_join(file_name)
				var res = ResourceLoader.load(full_path)
				if res is Item:
					all_items.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("ItemVault: Loaded %d items from %s" % [all_items.size(), items_folder_path])


func get_item_by_name(item_name : String) -> Item:
	for it in all_items:
		if it.item_name == item_name:
			return it
	return null
