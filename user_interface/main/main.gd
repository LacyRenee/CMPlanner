################################################################################
### The entry point for CMPlanner
### Always displays the application name in the header
### A PanelContainer is used for displaying the selected view
### A footer is used to display the options: ResourceList page, settings, etc...
################################################################################
extends Control

## Access to the container that is used for displaying the current page
@onready var panel_container_attacher: PanelContainer = %PanelContainerAttacher

## Scene path for the ResourceList page
const RESOURCE_LIST_SCENE_PATH : String = "res://user_interface/all_resources/all_resources.tscn"

## Scene path for the create/view resource page
const RESOURCE_SCENE_PATH : String = "res://user_interface/resource/resource.tscn"

## Scene path for the ResourceSchedule page
const RESOURCE_SCHEDULE_SCENE_PATH : String = "res://user_interface/resource_scheduler/resource_scheduler.tscn"

## Scene path for the Settings page
const SETTINGS_SCENE_PATH : String = "res://user_interface/settings/settings.tscn"

## Scene path for the schedule page
const SCHEDULE_SCENE_PATH : String = "res://user_interface/schedule/schedule.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	#region signals
	# Displays a selected resources information 
	SignalBus.connect("display_resource_info",display_resource_info_page, 0)
	
	# Displays the all resource page
	SignalBus.connect("display_all_resource_page", display_resource_page, 0)
	
	# Displays the new resource page
	SignalBus.connect("display_new_resource_page", display_new_resource_page, 0)
	
	# Displays the selected resource schedule page
	SignalBus.connect("display_selected_resource_schedule_page", display_selected_resource_schedule_view, 0)
	
	# Displays the generic resource schedule page
	SignalBus.connect("display_resource_schedule_page", display_resource_schedule_page, 0)
	
	# Displays the schedule page
	SignalBus.connect("display_schedule_page", display_schedule_page, 0)
	
	
	#endregion
	pass


## Displays the generic resource scheduler page
func display_resource_schedule_page() -> void:
	remove_scene_from_attacher()
	
	var resource_scheduler_page = load(RESOURCE_SCHEDULE_SCENE_PATH)
	var instance = resource_scheduler_page.instantiate()
	panel_container_attacher.add_child(instance)
	pass


## Displays the resource scheduler page
func display_selected_resource_schedule_view(p_resource : ResourceItem) -> void:
	remove_scene_from_attacher()
	
	var resource_schedule_page = load(RESOURCE_SCHEDULE_SCENE_PATH)
	var instance = resource_schedule_page.instantiate()
	panel_container_attacher.add_child(instance)
	
	SignalBus.schedule_selected_resource.emit(p_resource)
	pass


## Displays the new resource page
func display_new_resource_page() -> void:
	remove_scene_from_attacher()
	
	var resource_page = load(RESOURCE_SCENE_PATH)
	var instance = resource_page.instantiate()
	panel_container_attacher.add_child(instance)
	
	pass


## Displays a selected resource info page
func display_resource_info_page(resource) -> void:
	# Remove current scene
	remove_scene_from_attacher()
	
	# Display the Resource Page Information
	var resource_page = load(RESOURCE_SCENE_PATH)
	var instance = resource_page.instantiate()
	
	panel_container_attacher.add_child(instance)
	instance.display_selected_resource(resource)
	pass


## Displays the resource page 
func display_resource_page() -> void:
	# Remove any other page
	remove_scene_from_attacher()
	
	# Display the resource page
	var resource_list = load(RESOURCE_LIST_SCENE_PATH)
	var instance = resource_list.instantiate()
	panel_container_attacher.add_child(instance)
	pass


## Displays the settings page
func display_settings_page() -> void:
	# remove any other page
	remove_scene_from_attacher()
	
	var settings_page = load(SETTINGS_SCENE_PATH)
	var instance = settings_page.instantiate()
	panel_container_attacher.add_child(instance)
	pass


## Displays the schedule page
func display_schedule_page() -> void:
	# remove any other page
	remove_scene_from_attacher()
	
	var schedule_page = load(SCHEDULE_SCENE_PATH)
	var instance = schedule_page.instantiate()
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


## Displays the home page
func _on_btn_home_pressed() -> void:
	remove_scene_from_attacher()
	pass


## Displays the settings page
func _on_btn_settings_pressed() -> void:
	remove_scene_from_attacher()
	display_settings_page()
	pass


## Displays the schedule page
func _on_btn_schedule_pressed() -> void:
	SignalBus.display_schedule_page.emit()
	pass 
