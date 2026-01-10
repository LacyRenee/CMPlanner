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


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Create the user data resource folder
	var resource_path = get_resource_directory_filepath() 
	if !DirAccess.dir_exists_absolute(resource_path):
		DirAccess.make_dir_recursive_absolute(resource_path)
	else:
		print("Resource directory already exists")
	
	
	# Create the application's database file and the required Family student
	var db_path = get_database_filepath()
	if !ResourceLoader.load(db_path):
		var db : CMDatabase =  CMDatabase.new()
		
		var family_student : Student = Student.new()
		family_student.name = "Family"
		family_student.grade = "NA"
		family_student.is_active = true
		
		db.student_list.append(family_student)
				
		ResourceSaver.save(db, get_database_filepath())
	pass


## Retrieves the list of students
static func get_student_list() -> Array[Student]:
	var db = ResourceLoader.load(get_database_filepath())
	return db.student_list


## Adds a student to the student list file
static func add_student(p_student) -> void:
	var db = ResourceLoader.load(get_database_filepath())
	db.student_list.append(p_student)
	
	overwrite_database(db)
	pass


## Removes the selected student from the database
static func remove_student(p_student) -> void:
	var db = ResourceLoader.load(get_database_filepath())
	var index = db.student_list.find(p_student)
	db.student_list.remove_at(index)
	overwrite_database(db)
	pass


## Saves the edited student to the save file
static func save_edited_student(p_student : Student) -> void:
	var db = ResourceLoader.load(get_database_filepath())
	var index = db.student_list.students.find(p_student)
	db.student_list[index].name = p_student.name
	db.student_list[index].grade = p_student.grade
	
	overwrite_database(db)
	pass


## Saves the student file list
static func overwrite_database(p_file : CMDatabase) -> void:
	ResourceSaver.save(p_file, get_database_filepath())
	pass


## The user file path to the resource folder
static func get_resource_directory_filepath() -> String:
	return cm_database_path + RESOURCES_FOLDER_PATH


## The user file path to the user settings
static func get_database_filepath() -> String:
	return cm_database_path + SETTINGS_PATH


## Retrieves all of the resources in the Resource directory
static func get_all_resources() -> DirAccess:
	dir_access_resources = DirAccess.open(get_resource_directory_filepath())
	return dir_access_resources
