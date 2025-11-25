extends PlayerComponent
class_name PlayerInventory

@export var items : Array[Item] = []


func give_item(item: Item) -> void:
	items.append(item)
	player.player_audio.get_item()
	player.player_ui.display_gameplay_text("%s %s" % [tr("ITEM_OBTAIN"), tr(item.ui_item_name)])
	save_inventory()


## Adds the item to the array without triggering the text display
func add_item_raw(item : Item) -> void:
	items.append(item)
	save_inventory()


##Tries to take an item away from the inventory
func try_take_item(item_to_take : Item) -> Item:
	for item in items:
		if item.item_name == item_to_take.item_name:
			items.erase(item)
			player.player_audio.drop_item()
			player.player_ui.display_gameplay_text("%s %s" % [tr("ITEM_LOST"), tr(item.ui_item_name)])
			save_inventory()
			return item
	return null


func save_inventory() -> void:
	SaveDataServer.save_inventory(self)


func add_all_items() -> void:
	for item in ItemVault.all_items:
		add_item_raw(item)


func _load(data : SavedData) -> void:
	items.clear()
	for item in data.inventory:
		print("Loading item %s" % ItemVault.get_item_by_name(item))
		add_item_raw(ItemVault.get_item_by_name(item))
