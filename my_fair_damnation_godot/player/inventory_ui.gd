extends MarginContainer
class_name InventoryUI

const ITEM_LABEL = preload("res://player/player_ui/item_label.tscn")

@onready var item_description: Label = %ItemDescription
@onready var item_labels_v_box_container: VBoxContainer = %ItemLabelsVBoxContainer
@onready var player_inventory: PlayerInventory = $"../../PlayerInventory"


func display_inventory() -> void:
	for item_displayed in item_labels_v_box_container.get_children():
		item_displayed.queue_free()
	for item in player_inventory.items:
		var label : ItemLabel = ITEM_LABEL.instantiate() as ItemLabel
		label.set_up_button(item, self)
		item_labels_v_box_container.add_child(label)
		var separator = HSeparator.new()
		item_labels_v_box_container.add_child(separator)


func override_item_description(text : String) -> void:
	item_description.text = text
