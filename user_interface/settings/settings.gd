################################################################################
### Settings Page
### Allows for student creation and deletion
################################################################################
extends Control

## Access to the new student's name
@onready var popup_le_name: LineEdit = %PopupLeName

## Access to the grade options
@onready var option_grade: OptionButton = %OptionGrade

## Access to the student table
@onready var student_table: PanelContainer = %GridOfStudents

## Access to the popup panel that allows for a new student to be added
@onready var popup_panel: PopupPanel = %PopupPanel

## List of students saved on the user's drive
var student_directory : Array[Student]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Open the student directory
	student_directory = CMDatabaseUtilities.get_student_list()
	
	if student_directory.size() <= 1:
		student_table.visible = false
	else:
		student_table.visible = true
	
	
	pass


## Shows the popup panel to add a student
func _on_btn_add_student_pressed() -> void:
	popup_panel.show()
	
	# Populate the grade options
	for grade in CMDatabaseUtilities.GRADES:
		option_grade.add_item(grade.replace("_", " "))
	pass 


## Hides the add student popup panel
func _on_popup_btn_cancel_pressed() -> void:
	popup_panel.hide()
	pass 


## Saves the student to the database
func _on_popup_btn_save_pressed() -> void:
	var new_student : Student = Student.new()
	new_student.name = popup_le_name.text
	new_student.grade =  option_grade.selected
	new_student.is_active = true
	
	CMDatabaseUtilities.add_student(new_student)
	popup_panel.hide()
	
	SignalBus.refresh_student_table.emit()
	pass

## Calls the function to load JSON objects in as ResourceItems
func _on_button_pressed() -> void:
	CMDatabaseUtilities.parse_json_data()
	pass 
