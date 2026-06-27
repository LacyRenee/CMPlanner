extends Control

## Path to the memorize set
const MEMORIZE_SET_SCENE_PATH = preload("uid://d4m604xss1vsu")

## Holds a new memorize set
@onready var panel_container_new_set_holder: PanelContainer = %PanelContainerNewSetHolder


## List of all Memorize sets
@onready var option_button_study_set: OptionButton = %OptionButtonStudySet

## Container for the select study set to study
@onready var hbox_study_set: HBoxContainer = %HBoxStudySet

## Container to study a card
@onready var panel_container_card_holder: PanelContainer = %PanelContainerCardHolder

## Container for all the set actions
@onready var hbox_set_actions: HBoxContainer = %HBoxSetActions


var is_study_view : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate the study set dropdown
	var memorize_sets = CMDatabaseUtilities.get_all_memorize_sets()
	
	if memorize_sets != null:
		for i in memorize_sets:
			option_button_study_set.add_item(i.title)
			
		option_button_study_set.selected = -1
	pass


## Toggles the "Select a set to Study" view on or off
func set_study_view() -> void:
	if is_study_view:
		hbox_study_set.visible = true
		hbox_set_actions.visible = true
	else:
		hbox_study_set.visible = false
		hbox_set_actions.visible = false
	pass


## Displays the memorize set
func _on_btn_new_set_pressed() -> void:
	if panel_container_new_set_holder.get_child_count() == 0:
		var instance = MEMORIZE_SET_SCENE_PATH.instantiate()
		panel_container_new_set_holder.add_child(instance)
		
		is_study_view = false
		set_study_view()
	pass


## Displays the cards to be studied for the set
func _on_option_button_study_set_item_selected(index: int) -> void:
	
	pass
