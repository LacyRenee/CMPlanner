## Displays all of available resources and allows for the creation of new resources
extends Control

# Access to the ItemList for all resources
@onready var resource_list: ItemList = %ILAllResources

# Access to the new resource button
@onready var btn_add_resource_item: Button = %BtnAddResourceItem

var is_new_resource_page_toggled : bool = false


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Open the directory
	var directory = DirAccess.open(CmDatabase.get_db_resource_filepath())
	if directory != null:
		# Add all of the resources to the ItemList
		for file in directory.get_files():
			var resource = load(directory.get_current_dir() + "/" + file)
			var index = resource_list.add_item(resource.title)
			resource_list.set_item_metadata(index, resource)
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
