################################################################################
### Student row for the student table of the settings page
###############################################################################
extends HBoxContainer

## Access to the line edit for the student's name
@onready var le_name: LineEdit = %LeName

## Access to the line edit for the student's grade
@onready var option_grade: OptionButton = %OptionGrade

## Access to the save button on the form
@onready var btn_save: Button = %BtnSave

## Access to the edit button on the form
@onready var btn_edit: Button = %BtnEdit

## Access to the label for the popup title
@onready var lbl_popup_title: RichTextLabel = %LblPopupTitle

## Access to the confirmation panel to delete a student
@onready var popup_panel_confirm_delete: PopupPanel = %PopupPanelConfirmDelete

## Holds the resource for the student
var student : Student


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for grade in CMDatabaseUtilities.GRADES:
		option_grade.add_item(grade.replace("_", " "))
	pass


## Sets the student's name
func edit_name(p_name : String = '') -> void:
	le_name.text = p_name
	pass


## Sets the student's grade
func edit_grade(p_grade : CMDatabaseUtilities.GRADES) -> void:
	option_grade.selected = p_grade
	pass


## Sets the student resource variable
func set_student_resource(p_student) -> void:
	student = p_student
	pass


## Allows the student information to be edited
func _on_btn_edit_pressed() -> void:
	le_name.editable = true
	option_grade.disabled = false	
	btn_edit.visible = false
	btn_save.visible = true
	pass 


## Allows the student to be deleted
func _on_btn_delete_pressed() -> void:
	popup_panel_confirm_delete.show()
	lbl_popup_title.text = "Remove " + student.name + " ?"
	pass


## Saves the edited student information
func _on_btn_save_pressed() -> void:
	student.name = le_name.text
	student.grade = option_grade.selected as CMDatabaseUtilities.GRADES
	CMDatabaseUtilities.save_edited_student(student)
	le_name.editable = false
	option_grade.disabled = true
	btn_edit.visible = true
	btn_save.visible = false
	pass 


## Confirms if the user really wants to delete the student and 
## all associated assignments
func _on_btn_confirm_pressed() -> void:
	CMDatabaseUtilities.remove_student(student)
	SignalBus.refresh_student_table.emit()
	pass


## Close the panel on cancel
func _on_btn_cancel_pressed() -> void:
	popup_panel_confirm_delete.hide()
	pass 
