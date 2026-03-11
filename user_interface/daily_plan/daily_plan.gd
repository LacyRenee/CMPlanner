################################################################################
### Displays the daily assignments for all students
################################################################################
extends Control


## Access to the item list of students
@onready var item_list_student_filter: ItemList = %ItemListStudentFilter

## Access to the item list of subjects
@onready var item_list_subject_filter: ItemList = %ItemListSubjectFilter

## Access to the list of subjects
@onready var vbox_subject_panels: VBoxContainer = %VBoxSubjectPanels


## Path to the Panel subject scene
const PANEL_SUBJECT = preload("uid://bv6p480uv7ng2")

## Path to the Panel Student scene
const PANEL_STUDENT = preload("uid://buta3ts5akipn")

## Path to the Daily Assignment scene
const DAILY_ASSIGNMENT = preload("uid://bdbbx365itqk1")

## Student ID Meta data
const STUDENT_ID = "student_id"

## Group name for the student overview panel
const STUDENT_PANEL_GROUP = "student_panel"


## Today's date
var today : Calendar.Date = Calendar.Date.today()

## Holds the selected date
var selected_date = today

## Holds the day for the current date
var day_of_week : Time.Weekday = today.get_weekday()

## Holds the subjects to be displayed for today
var todays_subjects : Array[ResourceData.Subjects] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add the student filter to the view
	var student_list : Array[Student] = CMDatabaseUtilities.get_student_list()
	for student in student_list:
		if student.is_active:
			var index = item_list_student_filter.add_item(student.name)
			item_list_student_filter.set_item_metadata(index, student)
		
	# Add the subject and assignments
	create_daily_plan_assignments()
	
	# Add the list of active subjects to the subject filter
	for subject in todays_subjects:
		item_list_subject_filter.add_item(ResourceData.Subjects.keys()[subject].replace("_", " "))
	
	# Signal Functions
	SignalBus.connect("display_next_assignment", display_next_assignment, 0)
	pass


#region Daily Assignment Functions
## Creates the panel header for each subject
func create_daily_plan_assignments() -> void:
	var student_subject_list : Array[Subject] = CmDatabaseUtilities.get_subject_list()
	var student_list : Array[Student] = CMDatabaseUtilities.get_student_list()
	
	if student_subject_list.is_empty():
		return
	
	for index in ResourceData.Subjects:
		var panel_subject_scene = PANEL_SUBJECT.instantiate()
		vbox_subject_panels.add_child(panel_subject_scene)
		panel_subject_scene.set_subject(index)
		panel_subject_scene.visible = false
		
		for student in student_list:
			var panel_student_scene = PANEL_STUDENT.instantiate()
			panel_subject_scene.v_box_subject.add_child(panel_student_scene)
			panel_student_scene.set_student_name(student.name)
			panel_student_scene.set_meta(STUDENT_ID, student.resource_path)
			panel_student_scene.add_to_group(STUDENT_PANEL_GROUP)
			panel_student_scene.visible = false
			
			# Add the student subject assignments for the day to the subject view
			for subject_assignment in student_subject_list:
				# Only add active assignments 
				if subject_assignment.student == student and\
				   subject_assignment.is_finished == false and\
				   CMDatabaseUtilities.compare_strings(str(ResourceData.Subjects.keys()[subject_assignment.subject]), panel_subject_scene.get_subject()):
					panel_subject_scene.visible = true
					
					# Only add subjects that matches today
					if subject_assignment.week_days.has(day_of_week) and \
					   student == subject_assignment.student and \
					   CMDatabaseUtilities.compare_strings(ResourceData.Subjects.keys()[subject_assignment.subject], panel_subject_scene.get_subject()):
						
						# Only add the assignment if the start date is the same as today or after
						if !subject_assignment.start_date.is_empty():
							var split_date = subject_assignment.start_date.split("-")
							var year : int = int(split_date[2])
							var month : int = int(split_date[0])
							var day : int  = int(split_date[1])
							var formatted_date = CMDatabaseUtilities._calendar.Date.new(year, month, day)
						
							if formatted_date.is_equal(today) or formatted_date.is_after(today):
								panel_student_scene.visible = true
								create_assignment_view(subject_assignment, panel_student_scene)
						
						# Only add the assignment if the start after ResourceItem has all assignments completed
						if subject_assignment.start_after != null:
							for i in subject_assignment.start_after.assignments.size():
								if subject_assignment.start_after.assignments[i].progress != ResourceData.progress.Completed or\
								   subject_assignment.start_after.assignments[i].progress != ResourceData.progress.Omit_assignment:
									return
								else:
									panel_student_scene.visible = true
									create_assignment_view(subject_assignment, panel_student_scene)
	pass


## Creates the progress view for the first selected assignment that is not complete
func create_assignment_view(p_subject : Subject, p_container : Node) -> void:
	for first_incomplete in p_subject.assignments:
		if first_incomplete.start_date == today.to_string() and \
		   (first_incomplete.progress == ResourceData.progress.Completed or \
		   first_incomplete.progress == ResourceData.progress.Omit_assignment):
			create_assignment(p_subject, p_container, first_incomplete)
			continue
			
		create_assignment(p_subject, p_container, first_incomplete)
		return
	pass


## Create the assignment view for subjects with a list of assignments
func create_assignment(p_subject : Subject, p_container : Node, p_assignment : Assignment = null) -> void:
	# Create the assignment view
	var assignment_scene = DAILY_ASSIGNMENT.instantiate()
	p_container.vbox_student.add_child(assignment_scene)
	
	# Attach the subject for easy reference from the assignment scene
	assignment_scene.set_meta("subject", p_subject)
	
	# Remove the "Finish and Complete" for assignments that do not contain a division type
	if p_subject.resource.division_type != ResourceData.DivisionType.None:
		assignment_scene.option_button_progress.set_item_disabled(4, true)
		
	# Attach the assignment for easy reference from the assignment scene
	if p_assignment == null:
		assignment_scene.title = p_subject.resource.title
	else:
		assignment_scene.set_meta("assignment", p_assignment)
	
	# Specify title and collapisble based on progress state
	if p_assignment.progress == ResourceData.progress.Completed or\
	   p_assignment.progress == ResourceData.progress.Complete_and_finish:
		assignment_scene.title = p_subject.resource.title +\
		" - " + str(ResourceData.progress.keys()[p_assignment.progress]) +\
		" on " + p_assignment.completed_date
		
		assignment_scene.fold()
	elif p_assignment.progress == ResourceData.progress.Omit_assignment:
			assignment_scene.title = p_subject.resource.title +\
			 " - Assignment Omitted on " + p_assignment.completed_date 
			assignment_scene.fold()
	else:
		assignment_scene.title = p_subject.resource.title
	
	# Format the assignment label based on the number of divisions there are
	if p_subject.division_type != ResourceData.DivisionType.None:
		assignment_scene.lbl_division_title.text = p_assignment.title
	else:
		assignment_scene.lbl_division_title.text = ""
	
	assignment_scene.lbl_study_method.text = str(ResourceData.study_method.keys()[p_subject.study_method].replace("_", " "))
	assignment_scene.lbl_date.text = Calendar.Date.today()._to_string()
	assignment_scene.text_edit_notes.text = p_assignment.notes if !p_assignment.notes.is_empty() else ""
	
	assignment_scene.option_button_progress.selected = p_assignment.progress
	
	if p_assignment.progress == ResourceData.progress.Incomplete:
		CMDatabaseUtilities.save_assignment_start_date(p_subject, p_assignment, today.to_string())
	
	p_container.visible = true
	pass
#endregion


## Remove the assignment view
func refresh_page() -> void:
	var nodes = vbox_subject_panels.get_children()
	
	for n in nodes:
		n.call_deferred("queue_free")
	pass


## Display a new assignment when the previous assignment is either 
## completed or omitted 
func display_next_assignment() -> void:
	refresh_page()
	
	create_daily_plan_assignments()
	pass


#region Signal Functions
## Displays the following dates assignment plans
func _on_btn_next_daily_plan_pressed() -> void:
	pass

## Displays today's assignment plans
func _on_btn_today_plan_pressed() -> void:
	pass

## Displays yesterday's assignments
func _on_btn_previous_daily_plan_pressed() -> void:
	pass 

# Displays the selected student assignments
func _on_item_list_student_filter_multi_selected(index: int, selected: bool) -> void:
	# Student overview panels
	var student_panels = get_tree().get_nodes_in_group(STUDENT_PANEL_GROUP)
	
	# Select student in table and subject overview
	for i in range(item_list_student_filter.get_item_count()):
		if item_list_student_filter.is_selected(i):
			for panel in student_panels:
				if panel.get_meta(STUDENT_ID) == item_list_student_filter.get_item_metadata(i).resource_path:
					panel.visible = true
		else:
			for panel in student_panels:
				if panel.get_meta(STUDENT_ID) == item_list_student_filter.get_item_metadata(i).resource_path:
					panel.visible = false
	pass
#endregion
