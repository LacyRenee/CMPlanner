################################################################################
### Utility class to handle all of the database management for the application
################################################################################
class_name CMDatabaseUtilities
extends Node

## User resources folder
const RESOURCES_FOLDER_PATH = "/resources"

## File path for the user settings 
const SETTINGS_PATH = "/cm_database.tres"

## The student list resource
const STUDENT_LIST_PATH = "res://models/student_list.gd"

## Base path for the user's folder
static var cm_database_path : String =  OS.get_user_data_dir()

## The directory for all the resources
static var dir_access_resources : DirAccess

## Holds all the students 
static var student_list : StudentList


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Create the user data resource folder
	var resource_path = get_resource_directory_filepath() 
	if !DirAccess.dir_exists_absolute(resource_path):
		DirAccess.make_dir_recursive_absolute(resource_path)
	else:
		print("Resource directory already exists")
	
	
	# Create the settings file
	var settings_path = CmDatabaseUtilities.get_settings_resource_filepath()
	if !ResourceLoader.load(settings_path):
		create_settings_file()
	else:
		student_list = ResourceLoader.load(get_settings_resource_filepath())
	pass


## The user file path to the resource folder
static func get_resource_directory_filepath() -> String:
	return cm_database_path + RESOURCES_FOLDER_PATH


## The user file path to the user settings
static func get_settings_resource_filepath() -> String:
	return cm_database_path + SETTINGS_PATH


## Retrieves all of the resources in the Resource directory
static func get_all_resources() -> DirAccess:
	dir_access_resources = DirAccess.open(get_resource_directory_filepath())
	return dir_access_resources


static func remove_student(p_student) -> void:
	var index = student_list.students.find(p_student)
	student_list.students.remove_at(index)
	save_student_file(student_list)
	pass


## Creates the file for user settings
static func create_settings_file() -> void:
	student_list = StudentList.new()
	
	var family_student : Student = Student.new()
	family_student.name = "Family"
	family_student.grade =  "NA"
	family_student.is_active = true
	
	student_list.students.append(family_student)
	
	save_student_file(student_list)
	pass


## Saves the student file list
static func save_student_file(file : StudentList) -> void:
	ResourceSaver.save(file, get_settings_resource_filepath())
	pass


## Saves the edited student to the save file
static func save_edited_student(file : Student) -> void:
	var index = student_list.students.find(file)
	student_list.students[index].name = file.name
	student_list.students[index].grade = file.grade
	
	save_student_file(student_list)
	pass


## Adds a student to the student list file
static func add_student(p_student) -> void:
	var all_students = ResourceLoader.load(get_settings_resource_filepath())
	all_students.add_student(p_student)
	
	save_student_file(all_students)
	pass


## Retrieves the list of students
static func get_student_list() -> StudentList:
	student_list = ResourceLoader.load(get_settings_resource_filepath())
	return student_list
