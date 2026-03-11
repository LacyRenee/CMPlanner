################################################################################
### HBox Assignment Row
### Displays all of the information for the selected assignment
### for the selected ResourceItem
################################################################################
extends HBoxContainer

## Access to the progress options for the assignment
@onready var option_progress: OptionButton = %OptionProgress

## Access to the numbered assignment
@onready var label_count: RichTextLabel = %LabelCount

## Access to the title of the assignment
@onready var label_title: RichTextLabel = %LabelTitle

## Access to the assignment's completed date
@onready var label_date: LineEdit = %LabelDate

## Access to the assignment's notes
@onready var text_edit_notes: TextEdit = %TextEditNotes

## Access to the edit button for the assignment
@onready var button_edit: Button = %ButtonEdit

## Access to the save button for the assignment
@onready var button_save: Button = %ButtonSave


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for option in ResourceData.progress:
		option_progress.add_item(option.replace("_", " "))
	pass


## Returns the selected option
func get_option_progress() -> ResourceData.progress:
	return option_progress.selected


## Sets the progress option to the selected option
func set_option_progress(p_option : ResourceData.progress) -> void:
	option_progress.selected = p_option
	pass


## Sets the count indicator for the assignment
func set_label_count(p_count : String) -> void:
	label_count.text = p_count
	pass


## Sets the title of the assignment
func set_label_title(p_title : String) -> void:
	label_title.text = p_title
	pass


## Sets the assignment completed date
func set_label_date(p_date : String) -> void:
	if p_date.is_empty():
		label_date.text = "NA"
	else:
		label_date.text = p_date
	pass


## Returns the assignment completed date
func get_label_date() -> String:
	return label_date.text


## Gets the assignment notes
func get_notes() -> String:
	return text_edit_notes.text


## Sets the assignment notes
func set_notes(p_notes : String) -> void:
	text_edit_notes.text = p_notes
	pass


## Allows the Date, progress options, and notes to be editable
func _on_button_edit_pressed() -> void:
	label_date.editable = true
	option_progress.disabled = false
	text_edit_notes.editable = true
	
	button_edit.visible = false
	button_save.visible = true
	pass


## Saves the new assignment information
func _on_button_save_pressed() -> void:
	label_date.editable = false
	option_progress.disabled = true
	text_edit_notes.editable = false
	
	button_edit.visible = true
	button_save.visible = false
	
	if option_progress.selected == ResourceData.progress.Incomplete or\
	   option_progress.selected == ResourceData.progress.In_progress:
		label_date.text = "NA"
	else:
		label_date.text = Calendar.Date.today().to_string()
	
	SignalBus.update_resource_assignments.emit(\
		int(label_count.text) - 1,\
		label_date.text,\
		option_progress.selected,\
		text_edit_notes.text)
	pass
