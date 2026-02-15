################################################################################
### Displays the daily assignments for all students
################################################################################
extends Control

## Path to the Panel subject scene
const PANEL_SUBJECT = preload("uid://bv6p480uv7ng2")

## Path to the Daily Assignment scene
const DAILY_ASSIGNMENT = preload("uid://bdbbx365itqk1")

## Access to the item list of students
@onready var item_list_student_filter: ItemList = %ItemListStudentFilter

## Access to the item list of subjects
@onready var item_list_subject_filter: ItemList = %ItemListSubjectFilter

## Access to the list of subjects
@onready var vbox_subject_panels: VBoxContainer = %VBoxSubjectPanels


var today : Calendar.Date = Calendar.Date.today()
var day_of_week : Time.Weekday = today.get_weekday()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	# Add the student filter to the view
	var student_list : Array[Student] = CMDatabaseUtilities.get_student_list()
	for student in student_list:
		if student.is_active:
			var index = item_list_student_filter.add_item(student.name)
			item_list_student_filter.set_item_metadata(index, student)
	
	# Add the list of active subjects
	for subject in CMDatabaseUtilities.active_subjects:
		item_list_subject_filter.add_item(ResourceData.Subjects.keys()[subject])
	
	# Add the subject and assignments
	create_subject_panels()
	
	pass


## Creates the panel header for each subject 
func create_subject_panels() -> void:
	var student_subject_list : Array[Subject] = CmDatabaseUtilities.get_subject_list()
	var subject_list = ResourceData.Subjects
	
	if student_subject_list.is_empty():
		return
	
	for title in subject_list:
		var panel_scene = PANEL_SUBJECT.instantiate()
		panel_scene.get_child(0).get_child(0).text = title
		panel_scene.visible = false
		vbox_subject_panels.add_child(panel_scene)
	
	# Add the student subject assignments for the day to the subject view
	for subject_assignment in student_subject_list:
		if subject_assignment.week_days.has(day_of_week):
			add_assignment_to_subject_overview(subject_assignment)
	pass


## For each students, the assignment is added to the correct subject overview
func add_assignment_to_subject_overview(p_subject : Subject) -> void:
	var subject = ResourceData.Subjects.keys()[p_subject.subject]
	var nodes = vbox_subject_panels.get_children()
	
	for n in nodes:
		if n.get_child(0).get_child(0).text == subject:
			create_assignment_view(p_subject, n)
			n.visible = true
	pass


## Creates the progress view for the first selected assignment that is not complete
func create_assignment_view(p_subject : Subject, p_container : Node) -> void:
	# Keeps track of the number of assignments completed
	var assignment_number : int = 0
	
	for first_incomplete in p_subject.assignments:
		if first_incomplete.start_date == today.to_string() and \
		   (first_incomplete.progress == ResourceData.progress.Completed or \
		   first_incomplete.progress == ResourceData.progress.Omit_assignment) :
			create_assignment(p_subject, first_incomplete, p_container)
			continue
			
		create_assignment(p_subject, first_incomplete, p_container)
		return
			
		assignment_number += 1
	pass


func create_assignment(p_subject : Subject, p_assignment : Assignment, p_container : Node) -> void:
	var assignment_scene = DAILY_ASSIGNMENT.instantiate()
	p_container.get_child(0).add_child(assignment_scene)

	assignment_scene.set_meta("subject", p_subject)
	assignment_scene.set_meta("assignment", p_assignment)
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
	pass
