################################################################################
## Schedule Page
## Displays a table view of all active students and subjects.
## Displays a list of all active subjects and their corresponding assignments
## for each student. 
################################################################################
extends Control

## Path to the Panel subject scene
const PANEL_SUBJECT = preload("uid://bv6p480uv7ng2")

## Path to the Panel student scene
const PANEL_STUDENT = preload("uid://buta3ts5akipn")

## Path to the student lesson info scene
const STUDENT_LESSON_INFO = preload("uid://chj1la6p3ou7h")

## Path to the mobile student lesson info mobile scene
const STUDENT_LESSON_INFO_MOBILE = preload("uid://dji3o6xmi2iym")

## Group name for the student overview panel
const STUDENT_PANEL_GROUP = "student_panel"

# Student ID Meta data
const STUDENT_ID = "student_id"


## Access to the item list of students
@onready var item_list_students: ItemList = %ItemListStudents

## Access to the weekly overview table of assignments
@onready var vbox_weekly_overview_table: VBoxContainer = %VBoxWeeklyOverviewTable

## Access to the vbox to display an overview of all the active subjects
@onready var vbox_subject_overview : VBoxContainer = %VBoxSubjectView

## Access to the vbox to display an overview of all completed subjects
@onready var vbox_completed_subject_view: VBoxContainer = %VBoxCompletedSubjectView

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

## Access to the popup menu that redirects the user to the new ResourceItem page
@onready var popup_panel: PopupPanel = %PopupPanel


#TODO create mobile functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If the application is running on mobile, shorthand the table header
	if CMDatabaseUtilities.get_is_mobile():
		mobile_shorthand_table_header()
		item_list_students.max_columns = 0
	
	create_schedule_overview_table()
	
	create_subject_assignment_overview()
		
	# Signals the Schedule page to refresh
	SignalBus.connect("refresh_scheduled_subject_view", refresh_page)
	pass


## Refreshes the schedule page
func refresh_page() -> void:
	remove_children_from_scene()
	create_schedule_overview_table()
	create_subject_assignment_overview()
	pass


## Removes the children views from the schedule view
func remove_children_from_scene() -> void:	
	# Remove all students
	item_list_students.clear()
	
	# Need to remove all students (except the header) from the table
	for i in vbox_weekly_overview_table.get_child_count():
		# Don't remove the header!
		if i != 0:
			vbox_weekly_overview_table.get_child(i).call_deferred("queue_free")
		
		
	# Remove all assignments from the Active Subject Overview
	for i in vbox_subject_overview.get_child_count():
		vbox_subject_overview.get_child(i).call_deferred("queue_free")
	
	# Remove all assignments from the Completed Subject View
	for i in vbox_completed_subject_view.get_child_count():
		vbox_completed_subject_view.get_child(i).call_deferred("queue_free")
	pass


#region Table Schedule functions
## Creates a row for each student in the database
## Adds any corresponding, active subjects for the student
func create_schedule_overview_table() -> void:
	# Add the "Filter by student" and student rows to the weekly overview
	var student_list = CMDatabaseUtilities.get_student_list()
	var assignment_list = CMDatabaseUtilities.get_subject_list()
		
	for student in student_list:
		# Add the students to the filter list
		var index = item_list_students.add_item(student.name)
		item_list_students.set_item_metadata(index, student)
		
		# Create the row
		create_student_weekly_overview_row(student)
		
		# Add the student assignments
		var assignments = get_all_student_assignments(student, assignment_list)
		create_weekly_assignment_overview(student, assignments)
	pass


## Creates a row for each student in the weekly overview table
func create_student_weekly_overview_row(p_student : Student) -> void:
	var hbox : HBoxContainer = HBoxContainer.new()
	hbox.name = p_student.name
	hbox.set_meta(STUDENT_ID, p_student.resource_path)
	
	# Create column 1 with the student label
	var panel : PanelContainer = create_panel_container()
	var margin : MarginContainer = MarginContainer.new()
	var label1 : RichTextLabel = RichTextLabel.new()
	label1.text = p_student.name
	label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label1.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label1.fit_content = true
	label1.mouse_filter = Control.MOUSE_FILTER_PASS
	
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


## Creates the panel container for the table cell
func create_panel_container() -> PanelContainer:
	var container : PanelContainer = PanelContainer.new()
	container.add_theme_stylebox_override("panel", preload("uid://ckpswvy11b8mw"))
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(0, 100)
	container.mouse_filter = Control.MOUSE_FILTER_PASS
	return container


## Displays an overview of the weekly assignments for each student for the table view
func create_weekly_assignment_overview(p_student : Student, p_assignment_list : Array[Subject]) -> void:
	var student_rows = vbox_weekly_overview_table.get_children()
	var student_row : HBoxContainer
	
	for row in student_rows:
		if row.has_meta(STUDENT_ID):
			if row.get_meta(STUDENT_ID) == p_student.resource_path:
				student_row = row

	# Adds the assignment to each day it's assigned
	for assignment in p_assignment_list:
		if assignment.is_finished == false:
			for day in assignment.week_days:
				match day:
					ResourceData.week_day.Sunday:
						var label = create_weekly_assignment_label(assignment.subject)
						student_row.get_child(1).get_child(0).get_child(0).add_child(label)
					ResourceData.week_day.Monday:
						var label = create_weekly_assignment_label(assignment.subject)
						student_row.get_child(2).get_child(0).get_child(0).add_child(label)
					ResourceData.week_day.Tuesday:
						var label = create_weekly_assignment_label(assignment.subject)
						student_row.get_child(3).get_child(0).get_child(0).add_child(label)
					ResourceData.week_day.Wednesday:
						var label = create_weekly_assignment_label(assignment.subject)
						student_row.get_child(4).get_child(0).get_child(0).add_child(label)
					ResourceData.week_day.Thursday:
						var label = create_weekly_assignment_label(assignment.subject)
						student_row.get_child(5).get_child(0).get_child(0).add_child(label)
					ResourceData.week_day.Friday:
						var label = create_weekly_assignment_label(assignment.subject)
						student_row.get_child(6).get_child(0).get_child(0).add_child(label)
					ResourceData.week_day.Saturday:
						var label = create_weekly_assignment_label(assignment.subject)
						student_row.get_child(7).get_child(0).get_child(0).add_child(label)
	pass


## Creates the assignment label to be displayed under the day
func create_weekly_assignment_label(p_subject : ResourceData.Subjects) -> RichTextLabel:
	var label : RichTextLabel = RichTextLabel.new()
	label.text = ResourceData.Subjects.keys()[p_subject].replace("_", " ")
	label.fit_content = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return label


## Creates an array of all assignments for each student
func get_all_student_assignments(p_student : Student, p_assignment_list : Array[Subject]) -> Array[Subject]:
	var assignments : Array[Subject] = []
	
	for assignment in p_assignment_list:
		if assignment.student.name == p_student.name:
			assignments.append(assignment)
	
	return assignments
#endregion


#region Subject Overview Functions
## Creates the subject assignment overview
func create_subject_assignment_overview() -> void:
	var student_subject_list : Array[Subject] = CmDatabaseUtilities.get_subject_list()
	var student_list : Array[Student] = CMDatabaseUtilities.get_student_list()
	
	if student_subject_list.is_empty() or student_subject_list.is_empty():
		return
	
	# Add the subject panel
	for index in ResourceData.Subjects:
		# Add the subject panel to the active container
		var panel_active_subject_scene = PANEL_SUBJECT.instantiate()
		vbox_subject_overview.add_child(panel_active_subject_scene)
		panel_active_subject_scene.set_subject(index.replace("_", " "))
		panel_active_subject_scene.visible = false
		
		# Add the subject panel to the completed container
		var panel_completed_subject_scene = PANEL_SUBJECT.instantiate()
		vbox_completed_subject_view.add_child(panel_completed_subject_scene)
		panel_completed_subject_scene.set_subject(index)
		panel_completed_subject_scene.visible = false
		
		# Add each student to the subject
		for student in student_list:
			# Add the student panel to the active subject panel
			var panel_active_student_scene = PANEL_STUDENT.instantiate()
			panel_active_subject_scene.v_box_subject.add_child(panel_active_student_scene)
			panel_active_student_scene.set_student_name(student.name)
			panel_active_student_scene.set_meta(STUDENT_ID, student.resource_path)
			panel_active_student_scene.add_to_group(STUDENT_PANEL_GROUP)
			panel_active_student_scene.visible = false
			
			# Add the student panel to the completed subject panel
			var panel_completed_student_scene = PANEL_STUDENT.instantiate()
			panel_completed_subject_scene.v_box_subject.add_child(panel_completed_student_scene)
			panel_completed_student_scene.set_student_name(student.name)
			panel_completed_student_scene.set_meta(STUDENT_ID, student.resource_path)
			panel_completed_student_scene.add_to_group(STUDENT_PANEL_GROUP)
			panel_completed_student_scene.visible = false
		
			# Add the student subject assignments to the cvorresponding active/inactive subject tabs
			for subject_assignment in student_subject_list:
				if subject_assignment.student == student and\
				   subject_assignment.is_finished == false and\
				   CMDatabaseUtilities.compare_strings(str(ResourceData.Subjects.keys()[subject_assignment.subject]), panel_active_subject_scene.get_subject()):
						panel_active_subject_scene.visible = true
						create_subject_assignment(subject_assignment, panel_active_student_scene)
				elif subject_assignment.student == student and\
					 subject_assignment.is_finished == true and\
					 CMDatabaseUtilities.compare_strings(str(ResourceData.Subjects.keys()[subject_assignment.subject]), panel_completed_subject_scene.get_subject()):
					panel_completed_subject_scene.visible = true
					create_subject_assignment(subject_assignment, panel_completed_student_scene)
	pass


## Creates the assignments for the specified subject for all students
func create_subject_assignment(p_assignment : Subject, p_container : Node) -> void:
	var student_lesson_info_scene
	
	if CMDatabaseUtilities.get_is_mobile():
		student_lesson_info_scene = STUDENT_LESSON_INFO_MOBILE.instantiate()
	else:
		student_lesson_info_scene = STUDENT_LESSON_INFO.instantiate()

	p_container.vbox_student.add_child(student_lesson_info_scene)
	
	# TODO Turn into a link to view the resource?
	student_lesson_info_scene.lbl_subject_title.text = p_assignment.resource.title
	student_lesson_info_scene.lbl_lesson_method.text = \
			ResourceData.study_method.keys()[p_assignment.study_method].replace("_", " ")
	student_lesson_info_scene.set_subject(p_assignment)
	
	
	# Format the "Start label" text
	var start_title : String = ""
	if p_assignment.start_date.is_empty():
		start_title = "Start After: " + p_assignment.start_after.resource.title
	else:
		start_title = "Start: " + p_assignment.start_date
	student_lesson_info_scene.lbl_start.text = start_title
	
	# Format the division type text (e.g., Chapter 1 - 10)
	if p_assignment.division_type == ResourceData.DivisionType.None:
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
		background_color.bg_color = Color("#08457e")
		
		match day:
			ResourceData.week_day.Sunday:
				student_lesson_info_scene.lbl_day_1.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_1.add_theme_stylebox_override("normal", background_color)
			ResourceData.week_day.Monday:
				student_lesson_info_scene.lbl_day_2.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_2.add_theme_stylebox_override("normal", background_color)
			ResourceData.week_day.Tuesday: 
				student_lesson_info_scene.lbl_day_3.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_3.add_theme_stylebox_override("normal", background_color)
			ResourceData.week_day.Wednesday:
				student_lesson_info_scene.lbl_day_4.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_4.add_theme_stylebox_override("normal", background_color)
			ResourceData.week_day.Thursday:
				student_lesson_info_scene.lbl_day_5.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_5.add_theme_stylebox_override("normal", background_color)
			ResourceData.week_day.Friday:
				student_lesson_info_scene.lbl_day_6.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_6.add_theme_stylebox_override("normal", background_color)
			ResourceData.week_day.Saturday:
				student_lesson_info_scene.lbl_day_7.add_theme_color_override("default_color", Color.WHITE)
				student_lesson_info_scene.lbl_day_7.add_theme_stylebox_override("normal", background_color)
	p_container.visible = true
	pass
#endregion


#region Signal functions

## Directs the user to the ResourceItem page
func _on_btn_yes_create_resource_pressed() -> void:
	SignalBus.display_new_resource_page.emit()
	pass


## Hides the popup panel
func _on_btn_cancel_popup_pressed() -> void:
	popup_panel.hide()
	pass


## Displays the schedule resource page
func _on_btn_schedule_resource_pressed() -> void:
	
	# Navigate the user to the resource page if no ResourceItems exist
	if CMDatabaseUtilities.get_all_resources().is_empty():
		popup_panel.show()
	else:
		SignalBus.display_resource_schedule_page.emit()
	pass 


## Displays the table row and subject overview associated with the selected student
func _on_item_list_students_multi_selected(_index : int, _selected : bool) -> void:
	# Student table rows
	var student_rows = vbox_weekly_overview_table.get_children()
	
	# Student overview panels
	var student_panels = get_tree().get_nodes_in_group(STUDENT_PANEL_GROUP)
	
	# Select student in table and subject overview
	for i in range(item_list_students.get_item_count()):
		if item_list_students.is_selected(i):
			for row in student_rows:
				if row.get_meta(STUDENT_ID) == item_list_students.get_item_metadata(i).resource_path:
					row.visible = true
			for panel in student_panels:
				if panel.get_meta(STUDENT_ID) == item_list_students.get_item_metadata(i).resource_path:
					panel.visible = true
		else:
			for row in student_rows:
				if row.get_meta(STUDENT_ID) == item_list_students.get_item_metadata(i).resource_path:
					row.visible = false
			for panel in student_panels:
				if panel.get_meta(STUDENT_ID) == item_list_students.get_item_metadata(i).resource_path:
					panel.visible = false
	pass 
#endregion


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
