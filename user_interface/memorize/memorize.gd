extends Control

## Path to the memorize set
const MEMORIZE_SET_SCENE_PATH = preload("uid://d4m604xss1vsu")

## Holds a new memorize set
@onready var panel_container_holder: PanelContainer = %PanelContainerHolder

## List of all Memorize sets
@onready var option_button_study_set: OptionButton = %OptionButtonStudySet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate the study set dropdown
	var memorize_sets = CMDatabaseUtilities.get_all_memorize_sets()
	
	if memorize_sets != null:
		for i in memorize_sets:
			option_button_study_set.add_item(i.title)
	pass


## Displays the memorize set
func _on_btn_new_set_pressed() -> void:
	if panel_container_holder.get_child_count() == 0:
		var instance = MEMORIZE_SET_SCENE_PATH.instantiate()
		panel_container_holder.add_child(instance)
	pass
