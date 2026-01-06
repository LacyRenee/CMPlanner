################################################################################
### Schedule Page
### I want to display a weekly and daily schedule? Or put daily on the home page
################################################################################
extends Control

## Access to the hbox to add all available students
@onready var h_box_students: HBoxContainer = %HBoxStudents

## Access to the hbox to add all available subjects
@onready var h_box_subjects: HBoxContainer = %HBoxSubjects


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add all students
	var student_list = CMDatabaseUtilities.get_student_list()
	for student in student_list.students:
		create_student_checkbox(student.name)
	pass


## Creates a checkbox for each student
func create_student_checkbox(p_name) -> void:
	var margin_container : MarginContainer = MarginContainer.new()
	
	var checkbox : CheckBox = CheckBox.new()
	checkbox.text = p_name
	checkbox.custom_minimum_size = Vector2(100,10)
	checkbox.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	var control_spacer : Control = Control.new()
	control_spacer.custom_minimum_size = Vector2(100, 10)
	
	margin_container.add_child(checkbox)
	h_box_students.add_child(margin_container)
	h_box_students.add_child(control_spacer)
	pass


func _on_btn_schedule_resource_pressed() -> void:
	pass 
