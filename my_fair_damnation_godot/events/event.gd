extends Resource
class_name Event

## The name of the event, for code uses only. It's not meant to be displayed
## to the player.
@export var event_name : String
## Event description, for development clarity
@export_multiline var event_description : String
## If true, the event won't be added to the current event list
@export var event_is_trigger := false
@export var is_one_day_only := false
