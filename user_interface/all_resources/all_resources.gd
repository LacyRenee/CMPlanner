################################################################################
### AllResource displays all resource: books, videos, etc...
### Allows access to create a new resource
################################################################################
extends Control

# Access to the ItemList for all resources
@onready var resource_list: ItemList = %ILAllResources

# Access to the "add new resource" button
@onready var btn_add_resource_item: Button = %BtnAddResourceItem


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 
	var resources = CmDatabaseUtilities.get_all_resources()
	if !resources.is_empty():
		# Add all of the resources to the ItemList
		for r in resources:
			var index = resource_list.add_item(r.title)
			resource_list.set_item_metadata(index, r)
	pass 


## Gets the selected Resource
func _on_il_all_resources_item_selected(index: int) -> void:
	var selected_resource = resource_list.get_item_metadata(index)
	SignalBus.display_resource_info.emit(selected_resource)
	pass


## Displays the new resource form page
func _on_btn_add_resource_item_pressed() -> void:
	SignalBus.display_new_resource_page.emit()
	pass 
