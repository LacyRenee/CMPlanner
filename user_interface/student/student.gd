################################################################################
### Student row for the student table of the settings page
###############################################################################
extends HBoxContainer

## Access to the line edit for the student's name
@onready var le_name: LineEdit = %LeName

## Access to the line edit for the student's grade
@onready var le_grade: LineEdit = %LeGrade

## Access to the save button on the form
@onready var btn_save: Button = %BtnSave

## Access to the edit button on the form
@onready var btn_edit: Button = %BtnEdit

## Holds the resource for the student
var student : Student


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


## Sets the student's name
func edit_name(p_name : String) -> void:
	le_name.text = p_name
	pass


## Sets the student's grade
func edit_grade(p_grade : String) -> void:
	le_grade.text = p_grade
	pass


## Sets the student resource variable
func set_student_resource(p_student) -> void:
	student = p_student
	pass


## Allows the student information to be edited
func _on_btn_edit_pressed() -> void:
	le_name.editable = true
	le_grade.editable = true
	
	btn_edit.visible = false
	btn_save.visible = true
	pass 


## Allows the student to be deleted
func _on_btn_delete_pressed() -> void:
	CMDatabaseUtilities.remove_student(student)
	SignalBus.refresh_student_table.emit()
	pass


## Saves the edited student information
func _on_btn_save_pressed() -> void:
	student.name = le_name.text
	student.grade = le_grade.text
	CMDatabaseUtilities.save_edited_student(student)
	le_name.editable = false
	le_grade.editable = false
	btn_edit.visible = true
	btn_save.visible = false
	pass 
