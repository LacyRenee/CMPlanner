## The entry point into the application
## Need to add a GUI as a singleton
## The key to scene organization is to consider the SceneTree in relational terms rather than spatial terms. 
## Are the nodes dependent on their parent's existence? If not, then they can thrive all by themselves somewhere else. 
## If they are dependent, then it stands to reason that they should be children of that parent 
## (and likely part of that parent's scene if they aren't already).

extends Control

@onready var panel_container_attacher: PanelContainer = %PanelContainerAttacher

const RESOURCE_LIST_PATH : String = "res://user_interface/all_resources/all_resources.tscn"
const RESOURCE_PAGE_PATH : String = "res://user_interface/resource/resource.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Create the user data resource folder
	var path = CmDatabase.get_db_resource_filepath() 
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	# Displays a selected resources information 
	SignalBus.connect("display_resource_info",display_resource_info_page, 0)
	
	# Displays the all resource page
	SignalBus.connect("display_all_resource_page", display_resource_page, 0)
	
	# Displays the new resource page
	SignalBus.connect("display_new_resource_page", display_new_resource_page, 0)
	pass


## Displays the new resource page
func display_new_resource_page() -> void:
	remove_scene_from_attacher()
	
	var resource_page = load(RESOURCE_PAGE_PATH)
	var instance = resource_page.instantiate()
	panel_container_attacher.add_child(instance)
	
	pass

## Displays a selected resource info page
func display_resource_info_page(resource) -> void:
	# Remove current scene
	remove_scene_from_attacher()
	
	# Display the Resource Page Information
	var resource_page = load(RESOURCE_PAGE_PATH)
	var instance = resource_page.instantiate()
	
	panel_container_attacher.add_child(instance)
	instance.display_selected_resource(resource)
	pass


## Displays the resource page 
func display_resource_page() -> void:
	# Remove any other page
	remove_scene_from_attacher()
	
	# Display the resource page
	var resource_list = load(RESOURCE_LIST_PATH)
	var instance = resource_list.instantiate()
	panel_container_attacher.add_child(instance)
	pass


## Remove current container from the PanelContainerAttacher
func remove_scene_from_attacher() -> void:
	if panel_container_attacher.get_child_count():
		panel_container_attacher.remove_child(panel_container_attacher.get_child(0))


## Displays the resource page
func _on_btn_resources_pressed() -> void:
	# Remove any child nodes
	remove_scene_from_attacher()
	
	display_resource_page()
	
	pass 
	

## Doisplays the home page
func _on_btn_home_pressed() -> void:
	remove_scene_from_attacher()
	pass
