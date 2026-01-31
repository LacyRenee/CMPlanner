extends Control

const STUDENT_ROW_GROUP = "student_row"

@onready var h_box_students: HBoxContainer = %HBoxStudents


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add the student checkboxes to the view
	var student_list : Array[Student] = CMDatabaseUtilities.get_student_list()
	for student in student_list:
		create_student_checkbox(student.name)
	
	var assignment_list : Array[Subject] = CMDatabaseUtilities.get_subject_list()
	for assignment in assignment_list:
		create_assignment_view(assignment)
	
	pass 


## Creates the progress view for the selected assignment
func create_assignment_view(p_assignment : Subject) -> void:
	
	pass


## Creates a checkbox for each student
func create_student_checkbox(p_name) -> void:
	var margin_container : MarginContainer = MarginContainer.new()
	
	var checkbox : CheckBox = CheckBox.new()
	checkbox.text = p_name
	checkbox.custom_minimum_size = Vector2(100,10)
	checkbox.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	checkbox.pressed.connect(_on_student_checkbox_pressed.bind())
	checkbox.add_to_group(STUDENT_ROW_GROUP)
	
	var control_spacer : Control = Control.new()
	control_spacer.custom_minimum_size = Vector2(100, 10)
	
	margin_container.add_child(checkbox)
	h_box_students.add_child(margin_container)
	h_box_students.add_child(control_spacer)
	pass


func _on_student_checkbox_pressed() -> void:
	var checkboxes : Array[CheckBox] = []
	var rows : Array[HBoxContainer] = []
	var group = get_tree().get_nodes_in_group(STUDENT_ROW_GROUP)
	
	# Separate the checkboxes from the rows
	for row in group:
		if row.is_class("CheckBox"):
			checkboxes.append(row)
		else:
			rows.append(row)
			pass
	
	# Show the selected students 
	for check in checkboxes:
		if check.button_pressed == true:
			for row in rows:
				if row.name.begins_with(check.text):
					row.visible = true
		else:
			for row in rows:
				if row.name.begins_with(check.text):
					row.visible = false
	pass
