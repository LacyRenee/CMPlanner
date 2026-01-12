################################################################################
### Schedule Page
### I want to display a weekly and daily schedule? Or put daily on the home page
################################################################################
extends Control

const STUDENT_ROW_GROUP = "student_row"

## Access to the hbox to add all available students
@onready var h_box_students: HBoxContainer = %HBoxStudents

## Access to the weekly overview table of assignments
@onready var vbox_weekly_overview_table: VBoxContainer = %VBoxWeeklyOverviewTable

## Access to the hbox to add all available subjects
@onready var h_box_subjects: HBoxContainer = %HBoxSubjects


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add the "Filter by student" and student rows to the weekly overview
	var student_list = CMDatabaseUtilities.get_student_list()
	var assignment_list = CMDatabaseUtilities.get_subject_list()
	for student in student_list:
		create_student_checkbox(student.name)
		create_student_weekly_overview_row(student)
		var assignments = get_all_student_assignments(student, assignment_list)
		create_weekly_assignment_overview(student, assignments)
	
	pass


## Creates an array of all assignments for each student
func get_all_student_assignments(p_student : Student, p_assignment_list : Array[Subject]) -> Array[Subject]:
	var assignments : Array[Subject] = []
	
	for assignment in p_assignment_list:
		if assignment.student.has(p_student):
			assignments.append(assignment)
	
	return assignments


## Creates a row for each student in the weekly overview table
func create_student_weekly_overview_row(p_student : Student) -> void:
	var hbox : HBoxContainer = HBoxContainer.new()
	hbox.name = p_student.name
	hbox.add_to_group(STUDENT_ROW_GROUP)
	
	# Create column 1 with the student label
	var panel : PanelContainer = create_panel_container()
	var margin : MarginContainer = MarginContainer.new()

	var label1 : RichTextLabel = RichTextLabel.new()
	label1.text = p_student.name
	label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label1.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label1.fit_content = true
	
	margin.add_child(label1)
	panel.add_child(margin)
	hbox.add_child(panel)
	
	for column in 7:
		var column_container : PanelContainer = create_panel_container()
		var column_margin : MarginContainer = MarginContainer.new()
		column_container.add_child(column_margin)
		hbox.add_child(column_container)
	
	vbox_weekly_overview_table.add_child(hbox)
	pass


## Creates the 
func create_panel_container() -> PanelContainer:
	var container : PanelContainer = PanelContainer.new()
	container.add_theme_stylebox_override("panel", preload("uid://ckpswvy11b8mw"))
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(0, 100)
	return container


## Displays an overview of the weekly assignments
func create_weekly_assignment_overview(p_student : Student, p_assignment_list : Array[Subject]) -> void:
	var student_rows = vbox_weekly_overview_table.get_children()
	var student_row : HBoxContainer
	
	for row in student_rows:
		if row.name.begins_with(p_student.name):
			student_row = row
	
	for assignment in p_assignment_list:
		for day in assignment.week_days:
			var label = create_weekly_assignment_label(assignment.subject, assignment.resource.title)
			match day:
				ResourceData.week_day.Sunday:
					student_row.get_child(1).add_child(label)
					pass
				ResourceData.week_day.Monday:
					student_row.get_child(2).add_child(label)
					pass
				ResourceData.week_day.Tuesday:
					student_row.get_child(3).add_child(label)
					pass
				ResourceData.week_day.Wednesday:
					student_row.get_child(4).add_child(label)
					pass
				ResourceData.week_day.Thursday:
					student_row.get_child(5).add_child(label)
					pass
				ResourceData.week_day.Friday:
					student_row.get_child(6).add_child(label)
					pass
				ResourceData.week_day.Saturday:
					student_row.get_child(7).add_child(label)
					pass
	pass


## Creates the assignment label to be displayed under the day
func create_weekly_assignment_label(p_subject : ResourceData.Subjects, p_title : String) -> RichTextLabel:
	var label : RichTextLabel = RichTextLabel.new()
	label.text = ResourceData.Subjects.keys()[p_subject] + " - " + p_title
	return label


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


## Displays the schedule resource page
func _on_btn_schedule_resource_pressed() -> void:
	SignalBus.display_resource_schedule_page.emit()
	pass 
