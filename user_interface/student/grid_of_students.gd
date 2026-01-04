################################################################################
### Students Table - displays all of the students
################################################################################
extends Control

## Access to the table
@onready var v_box_container: VBoxContainer = %VBoxContainer

## Access to the table header
@onready var table_header: HBoxContainer = %TableHeader

## file path to the student row scene
const STUDENT_SCENE_PATH = preload("uid://dndwdy5tdbq1l")

## Holds a list of all the students
var student_list : StudentList


## Called the first time the node enters the tree scene
func _ready() -> void:
	refresh_student_list()
	
	# Refresh page when a student is added or removed
	SignalBus.connect("refresh_student_table", refresh_student_list)
	pass


## Refreshes the student table view
func refresh_student_list() -> void:
	remove_all_students()
	
	student_list = CMDatabaseUtilities.get_student_list()
	
	var family_count = 1
	for student in student_list.students:
		# Don't add family to the list
		if family_count == 1: 
			pass
		else:
			var instance = STUDENT_SCENE_PATH.instantiate()
			v_box_container.add_child(instance)
			
			instance.edit_name(student.name)
			instance.edit_grade(student.grade)
			instance.set_student_resource(student)
		family_count += 1
	pass


## Removes all of the students from the table
func remove_all_students() -> void:
	if v_box_container.get_child_count() > 1:
		var children = v_box_container.get_children()
		var count = 1
		for child in children:
			if count  == 1:
				pass
			else:
				v_box_container.remove_child(child)
			count += 1
	pass


## Adds the new student to the table
func create_student_row(p_student) -> void:
	var instance = STUDENT_SCENE_PATH.instantiate()
	v_box_container.add_child(instance)
	
	instance.edit_name(p_student[0])
	instance.edit_grade(p_student[1])
	
	pass
