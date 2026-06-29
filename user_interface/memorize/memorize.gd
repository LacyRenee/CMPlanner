################################################################################
### Memorize Page - Allows for the creation and study of sets
################################################################################
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

## Access to the Card title to be studied
@onready var lbl_card_title: RichTextLabel = %LblCardTitle

## Access to the card count to be studied
@onready var lbl_card_count: RichTextLabel = %LblCardCount

## Access to the card subtitle to be studied
@onready var lbl_card_subtitle: RichTextLabel = %LblCardSubtitle

## Access to the card content to be studied 
@onready var lbl_card_content: RichTextLabel = $VBoxContainer/PanelContainerCardHolder/VBoxContainer/HBoxContainer/PanelCardStudy/MarginContainer/VBoxContainer/LblCardContent

## Displays the previous study card
@onready var btn_card_previous: Button = %BtnCardPrevious

## Displays the next study card
@onready var btn_card_next: Button = %BtnCardNext

## Access to the popup panel
@onready var popup_panel: PopupPanel = %PopupPanel

## Access to the popup title
@onready var lbl_title: RichTextLabel = %LblTitle

## Access to the popup content
@onready var lbl_content: RichTextLabel = %LblContent

## Used to toggle between creation view and study view
var is_study_view : bool = false

## Holds the cards to be studied
var study_set : Array[Card] = []

## Counter for the study set
var study_set_counter : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate the study set dropdown
	var memorize_sets = CMDatabaseUtilities.get_all_memorize_sets()
	
	if memorize_sets != null:
		for i in memorize_sets.size():
			if memorize_sets[i].is_finished == false:
				option_button_study_set.add_item(memorize_sets[i].title)
				option_button_study_set.set_item_metadata(i, memorize_sets[i])
			
		option_button_study_set.selected = -1
	pass


## Toggles the "Select a set to Study" view on or off
func set_study_view() -> void:
	if is_study_view:
		hbox_study_set.visible = true
		hbox_set_actions.visible = true
		panel_container_new_set_holder.visible = false
	else:
		hbox_study_set.visible = false
		hbox_set_actions.visible = false
		panel_container_new_set_holder.visible = true
	pass


## Toggles the study card buttons enabled or disabled
func toggle_study_card_buttons(p_prev : bool, p_next : bool) -> void:
	btn_card_previous.disabled = p_prev
	btn_card_next.disabled = p_next
	pass


## Sets the study card text
func set_study_card_text(p_title : String, p_count : int, p_content : String, p_subtitle : String = "") -> void:
	lbl_card_title.text = p_title
	lbl_card_count.text = CMDatabaseUtilities.get_study_card_counter_label(p_count)
	lbl_card_content.text = p_content
	lbl_card_subtitle.text = p_subtitle
	
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
	panel_container_card_holder.visible = true
	panel_container_new_set_holder.visible = false
	hbox_set_actions.visible = true
	
	# Create the study cards
	var study_set_copy : Array[Card] = option_button_study_set.get_item_metadata(index).card_list
	
	if !study_set_copy.is_empty():
		for i in study_set_copy.size():
			study_set.append(study_set_copy[i])
			
			if study_set[i].is_finished == false:
				break
	
	if study_set.is_empty():
		toggle_study_card_buttons(true, true)
	else:
		toggle_study_card_buttons(true, false)
		
		# Display the first card
		set_study_card_text(study_set[0].title, 0, study_set[0].content, study_set[0].subtitle)	
	pass


## Displays the previous study card
func _on_btn_study_card_previous_pressed() -> void:
	if (study_set_counter - 1) == 0:
		set_study_card_text(study_set[0].title, 0, study_set[0].content, study_set[0].subtitle)
		toggle_study_card_buttons(true, false)
		
		# Go back one item in the array
		study_set_counter -= 1
	pass


## Displays the next study card
func _on_btn_study_card_next_pressed() -> void:
	# Check if we're at the end of the study set
	if (study_set_counter + 1) == study_set.size():
		set_study_card_text("", 0, "You've finished the set! Take a break!")
		toggle_study_card_buttons(false, true)
		
		# Go to next item in study array
		study_set_counter += 1
		
	match study_set_counter:
		0:
			pass
		1:
			pass
	pass


## Delete the selected memorize set
func _on_btn_delete_memorize_set_pressed() -> void:
	popup_panel.show()
	var selected_set : Set = option_button_study_set.get_item_metadata(option_button_study_set.selected)
	lbl_title.text = "Warning!"
	lbl_content.text = "Are you sure you want to remove the memorize set: " + selected_set.title + "?"
	pass


## Removes the selected memorize set on confirmation
func _on_popup_btn_ok_pressed() -> void:
	var selected_set : Set = option_button_study_set.get_item_metadata(option_button_study_set.selected)
	CMDatabaseUtilities.remove_set(selected_set)
	SignalBus.display_memorize_page.emit()
	pass 


## Hides the popup
func _on_popup_btn_cancel_pressed() -> void:
	popup_panel.hide()
	pass


## Returns the user to the creation/edit view
func _on_btn_edit_memorize_set_pressed() -> void:
	pass
