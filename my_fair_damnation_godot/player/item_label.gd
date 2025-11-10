extends Label
class_name ItemLabel

var inventory_ui : InventoryUI
var item_description : String


func set_up_button(item : Item, _inventory_ui : InventoryUI) -> void:
	text = item.ui_item_name
	inventory_ui = _inventory_ui
	item_description = item.ui_item_description


func _on_mouse_entered() -> void:
	inventory_ui.override_item_description(item_description)
