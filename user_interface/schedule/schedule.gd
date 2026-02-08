################################################################################
## Schedule Page
## Displays a table view of all active students and subjects.
## Displays a list of all active subjects and their corresponding assignments
## for each student. 
################################################################################
extends Control

## Group name for all the students in the table view
const STUDENT_ROW_GROUP = "student_row"

## Path to the Panel subject scene
const PANEL_SUBJECT = preload("uid://bv6p480uv7ng2")

## Path to the sutdent lesson info scene
const STUDENT_LESSON_INFO = preload("uid://chj1la6p3ou7h")


## Access to the hbox to add all available students as a checkbox
@onready var h_box_students_checkbox: HBoxContainer = %HBoxStudents

## Access to the weekly overview table of assignments
@onready var vbox_weekly_overview_table: VBoxContainer = %VBoxWeeklyOverviewTable

## Access to the vbox to display an overview of all the active subjects
@onready var vbox_subject_overview : VBoxContainer = %VBoxSubjectView

## Access to column1 header for the Schedule overview table
@onready var lbl_header_1: RichTextLabel = %LblHeader1

## Access to column2 header for the Schedule overview table
@onready var lbl_header_2: RichTextLabel = %LblHeader2

## Access to column3 header for the Schedule overview table
@onready var lbl_header_3: RichTextLabel = %LblHeader3

## Access to column4 header for the Schedule overview table
@onready var lbl_header_4: RichTextLabel = %LblHeader4

## Access to column5 header for the Schedule overview table
@onready var lbl_header_5: RichTextLabel = %LblHeader5

## Access to column6 header for the Schedule overview table
@onready var lbl_header_6: RichTextLabel = %LblHeader6

## Access to column7 header for the Schedule overview table
@onready var lbl_header_7: RichTextLabel = %LblHeader7

## Access to column8 header for the Schedule overview table
@onready var lbl_header_8: RichTextLabel = %LblHeader8

## Used to alternate view changes if the application is running on mobile
var is_mobile : bool = false

#TODO create mobile functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# If the application is running on mobile, shorthand the table header
	if OS.has_feature("mobile"):
		is_mobile = true
		mobile_shorthand_table_header()
		
	
	
	# Create a row for each student and add all active, associated subjects
	create_schedule_overview_table()
	
	# Create the Subject overview for all active subjects and their 
	# corresponding student assignments
	create_subject_overview()
	
	# Signals the Schedule page to refresh
	SignalBus.connect("refresh_scheduled_subject_view", refresh_page)
	pass


## Refreshes the schedule page
func refresh_page() -> void:
	remove_children_from_scene()
	
	create_schedule_overview_table()
	create_subject_overview()
	pass


## Removes the children views from the schedule view
func remove_children_from_scene() -> void:
	# Remove all students
	var student_row = h_box_students_checkbox.get_children()
	for row in student_row:
		row.call_deferred("queue_free")
	
	# Need to remove all students (except the header) from the table
	var table_rows = vbox_weekly_overview_table.get_children()
	var table_row_count = 0
	for row in table_rows:
		# Don't remove the header!
		if table_row_count != 0:
			row.call_deferred("queue_free")
		
		table_row_count += 1
		
	# Remove all assignments from the Subject Overview
	var overview_row = vbox_subject_overview.get_children()
	for row in overview_row:
		row.call_deferred("queue_free")
	pass


## Creates the checkboxes for all active students, 
## and the table row for each student and any assigned subjects
func create_schedule_overview_table() -> void:
	# Add the "Filter by student" and student rows to the weekly overview
	var student_list = CMDatabaseUtilities.get_student_list()
	var assignment_list = CMDatabaseUtilities.get_subject_list()
		
	for student in student_list:
		create_student_checkbox(student.name)
		create_student_weekly_overview_row(student)
		
		var assignments = get_all_student_assignments(student, assignment_list)
		create_weekly_assignment_overview(student, assignments)
	pass


## Creates the subject assignment overview
func create_subject_overview() -> void:
	var student_subject_list : Array[Subject] = CmDatabaseUtilities.get_subject_list()
	var subject_list = ResourceData.Subjects
	
	if student_subject_list.is_empty():
		return
	
	for item in subject_list:
		var panel_scene = PANEL_SUBJECT.instantiate()
		panel_scene.get_child(0).get_child(0).text = item
		panel_scene.visible = false
		vbox_subject_overview.add_child(panel_scene)
	
	# Add the student subject assignments to the subject view
	for subject_assignment in student_subject_list:
		add_assignment_to_subject_overview(subject_assignment)
	pass


## For each students, the assignment is added to the correct subject overview
func add_assignment_to_subject_overview(p_assignment : Subject) -> void:
	var subject = ResourceData.Subjects.keys()[p_assignment.subject]
	var nodes = vbox_subject_overview.get_children()
	
	for n in nodes:
		if n.get_child(0).get_child(0).text == subject:
			create_subject_assignment(p_assignment, n)
	pass


## Creates the assignments for the specified subject for all students
func create_subject_assignment(p_assignment : Subject, p_container : Node) -> void:
	var student_lesson_info_scene = STUDENT_LESSON_INFO.instantiate()
	p_container.get_child(0).add_child(student_lesson_info_scene)
	
	# TODO Turn into a link to view the resource?
	student_lesson_info_scene.lbl_student_name.text = p_assignment.student.name
	
	student_lesson_info_scene.lbl_subject_title.text = p_assignment.resource.title
	student_lesson_info_scene.lbl_lesson_method.text = \
			ResourceData.study_method.keys()[p_assignment.study_method].replace("_", " ")
	student_lesson_info_scene.set_subject(p_assignment)
	
	# Format the "Start label" text
	var start_title = "Start: " if !p_assignment.start_date.is_empty() else "Start After: "
	student_lesson_info_scene.lbl_start.text = start_title + p_assignment.start_date \
			if !p_assignment.start_date.is_empty() \
			else p_assignment.start_after
	
	# Format the division type text (e.g., Chapter 1 - 10)
	if student_lesson_info_scene.lbl_division_type.text == ResourceData.DivisionType.keys()[ResourceData.DivisionType.None]:
		student_lesson_info_scene.lbl_division_type.text = ""
	else:
		var count = p_assignment.assignments.size()
		student_lesson_info_scene.lbl_division_type.text = \
			ResourceData.DivisionType.keys()[p_assignment.resource.division_type] \
			+ " 1 - " \
			+ str(count)
	
	# Highlight the selected week days for the assignment 
	for day in p_assignment.week_days:
		var background_color : StyleBoxFlat = StyleBoxFlat.new()
		background_color.bg_color = Color.CADET_BLUE
		
		match day:
			0:
				student_lesson_info_scene.lbl_day_1.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_1.add_theme_stylebox_override("normal", background_color)
			1:
				student_lesson_info_scene.lbl_day_2.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_2.add_theme_stylebox_override("normal", background_color)
			2: 
				student_lesson_info_scene.lbl_day_3.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_3.add_theme_stylebox_override("normal", background_color)
			3:
				student_lesson_info_scene.lbl_day_4.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_4.add_theme_stylebox_override("normal", background_color)
			4:
				student_lesson_info_scene.lbl_day_5.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_5.add_theme_stylebox_override("normal", background_color)
			5:
				student_lesson_info_scene.lbl_day_6.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_6.add_theme_stylebox_override("normal", background_color)
			6:
				student_lesson_info_scene.lbl_day_7.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_7.add_theme_stylebox_override("normal", background_color)
	p_container.visible = true
	pass


## Creates an array of all assignments for each student
func get_all_student_assignments(p_student : Student, p_assignment_list : Array[Subject]) -> Array[Subject]:
	var assignments : Array[Subject] = []
	
	for assignment in p_assignment_list:
		if assignment.student.name == p_student.name:
			assignments.append(assignment)
	
	return assignments


## Creates a row for each student in the weekly overview table
func create_student_weekly_overview_row(p_student : Student) -> void:
	var hbox : HBoxContainer = HBoxContainer.new()
	hbox.name = p_student.name
	hbox.set_meta("student_id", p_student.resource_path)
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
		var column_vbox : VBoxContainer = VBoxContainer.new()
		column_margin.add_child(column_vbox)
		column_container.add_child(column_margin)
		hbox.add_child(column_container)
	
	vbox_weekly_overview_table.add_child(hbox)
	pass


## Creates the panel container for a cell
func create_panel_container() -> PanelContainer:
	var container : PanelContainer = PanelContainer.new()
	container.add_theme_stylebox_override("panel", preload("uid://ckpswvy11b8mw"))
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(0, 100)
	return container


## Displays an overview of the weekly assignments for each student for the table view
func create_weekly_assignment_overview(p_student : Student, p_assignment_list : Array[Subject]) -> void:
	var student_rows = vbox_weekly_overview_table.get_children()
	var student_row : HBoxContainer
	
	for row in student_rows:
		if row.has_meta("student_id"):
			if row.get_meta("student_id") == p_student.resource_path:
				student_row = row
	
	for assignment in p_assignment_list:
		for day in assignment.week_days:
			var label = create_weekly_assignment_label(assignment.subject, assignment.resource.title)
			match day:
				ResourceData.week_day.Sunday:
					student_row.get_child(1).get_child(0).get_child(0).add_child(label)
					pass
				ResourceData.week_day.Monday:
					student_row.get_child(2).get_child(0).get_child(0).add_child(label)
					pass
				ResourceData.week_day.Tuesday:
					student_row.get_child(3).get_child(0).get_child(0).add_child(label)
					pass
				ResourceData.week_day.Wednesday:
					student_row.get_child(4).get_child(0).get_child(0).add_child(label)
					pass
				ResourceData.week_day.Thursday:
					student_row.get_child(5).get_child(0).get_child(0).add_child(label)
					pass
				ResourceData.week_day.Friday:
					student_row.get_child(6).get_child(0).get_child(0).add_child(label)
					pass
				ResourceData.week_day.Saturday:
					student_row.get_child(7).get_child(0).get_child(0).add_child(label)
					pass
	pass


## Creates the assignment label to be displayed under the day
func create_weekly_assignment_label(p_subject : ResourceData.Subjects, p_title : String) -> RichTextLabel:
	var label : RichTextLabel = RichTextLabel.new()
	label.text = ResourceData.Subjects.keys()[p_subject]
	label.text += " - " + p_title if !is_mobile else ""
	label.fit_content = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL
	return label


## Creates a checkbox for each student
func create_student_checkbox(p_name) -> void:
	var margin_container : MarginContainer = MarginContainer.new()
	
	var checkbox : CheckBox = CheckBox.new()
	checkbox.text = p_name
	checkbox.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
	checkbox.custom_minimum_size = Vector2(100,10)
	checkbox.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	checkbox.pressed.connect(_on_student_checkbox_pressed.bind())
	checkbox.add_to_group(STUDENT_ROW_GROUP)
	
	var control_spacer : Control = Control.new()
	control_spacer.custom_minimum_size = Vector2(100, 10)
	
	margin_container.add_child(checkbox)
	h_box_students_checkbox.add_child(margin_container)
	h_box_students_checkbox.add_child(control_spacer)
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


#region Mobile Functions
## Changes the table overview header to the shorthand day
func mobile_shorthand_table_header():
	lbl_header_1.text = ""
	lbl_header_2.text = "Sun"
	lbl_header_3.text = "Mon"
	lbl_header_4.text = "Tue"
	lbl_header_5.text = "Wed"
	lbl_header_6.text = "Thu"
	lbl_header_7.text = "Fri"
	lbl_header_8.text = "Sat"
	pass

#endregion
