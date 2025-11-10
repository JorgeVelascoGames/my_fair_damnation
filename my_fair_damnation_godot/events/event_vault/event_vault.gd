@tool
extends Node

# EventVault is an autoload singleton that stores all Event resources for save/load and lookups.

## Directory paths (relative to project root) where Event resources are stored.
@export var events_folders_paths: Array[String] = []

## Array that holds all loaded Event resources.
@export var all_events: Array[Event] = []

## Inspector button to refresh the events list from the folder.
@export_tool_button("Refresh Events", "Callable") var refresh_events_button := _load_all_events


func _entered_tree() -> void:
	if Engine.is_editor_hint():
		_load_all_events()


## Loads all `.tres` or `.res` files as Event resources from the specified folder.
func _load_all_events() -> void:
	if not Engine.is_editor_hint():
		return
	all_events.clear()
	for events_folder_path in events_folders_paths:
		var dir = DirAccess.open(events_folder_path)
		if not dir:
			push_error("EventVault: Could not open directory: %s" % events_folder_path)
			return
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".res")):
				var full_path = events_folder_path.path_join(file_name)
				var res = ResourceLoader.load(full_path)
				if res is Event:
					all_events.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("EventVault: Loaded %d events from %s" % [all_events.size(), events_folder_path])


func get_event_by_string(event_name : String) -> Event:
	for event in all_events:
		if event.event_name == event_name:
			return event
	return null
