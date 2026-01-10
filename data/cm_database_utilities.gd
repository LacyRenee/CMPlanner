################################################################################
### Utility class to handle all of the database management for the application
################################################################################
class_name CMDatabaseUtilities
extends Node

## File path for the user settings 
const DATABASE_PATH = "/cm_database.tres"

## Base path for the user's folder
static var cm_database_path : String =  OS.get_user_data_dir()

## The directory for all the resources
static var dir_access_resources : DirAccess


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Create the application's database file
	if !get_database():
		var db : CMDatabase =  CMDatabase.new()
		
		# Family student required
		var family_student : Student = Student.new()
		family_student.name = "Family"
		family_student.grade = "NA"
		family_student.is_active = true
		
		db.student_list.append(family_student)
				
		ResourceSaver.save(db, get_database_filepath())
	pass


#region Student functions
## Retrieves the list of students
static func get_student_list() -> Array[Student]:
	var db = get_database()
	return db.student_list


## Adds a student to the student list file
static func add_student(p_student) -> void:
	var db = get_database()
	db.student_list.append(p_student)
	
	overwrite_database(db)
	pass


## Removes the selected student from the database
static func remove_student(p_student) -> void:
	var db = get_database()
	var index = db.student_list.find(p_student)
	db.student_list.remove_at(index)
	overwrite_database(db)
	pass


## Saves the edited student to the save file
static func save_edited_student(p_student : Student) -> void:
	var db = get_database()
	var index = db.student_list.students.find(p_student)
	db.student_list[index].name = p_student.name
	db.student_list[index].grade = p_student.grade
	
	overwrite_database(db)
	pass
#endregion


#region ResourceItem functions
## Retrieves all of the resources in the Resource directory
static func get_all_resources() -> Array[ResourceItem]:
	var db = get_database()
	return db.resource_list


## Saves the selected ResourceItem
static func save_resource_item(p_resource : ResourceItem) -> void:
	var db = get_database()
	db.resource_list.append(p_resource)
	overwrite_database(db)
	pass


## Updates the selected resourceItem
static func update_resource_item(p_resource : ResourceItem) -> void:
	var db = get_database()
	var index = db.resource_list.find(p_resource)
	db.resource_list[index] = p_resource
	overwrite_database(db)
	pass


## Removes the selected ResourceItem from the database
static func remove_resource_item(p_resource : ResourceItem) -> void:
	var db = get_database()
	var index = db.resource_list.find(p_resource)
	db.resource_list.remove_at(index)
	overwrite_database(db)
	pass
#endregion


## Retreives the database file
static func get_database() -> CMDatabase:
	var db : CMDatabase = ResourceLoader.load(get_database_filepath())
	return db


## Saves the student file list
static func overwrite_database(p_file : CMDatabase) -> void:
	ResourceSaver.save(p_file, get_database_filepath())
	pass


## The user file path to the user settings
static func get_database_filepath() -> String:
	return cm_database_path + DATABASE_PATH
