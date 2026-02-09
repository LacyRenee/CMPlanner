################################################################################
### Utility class to handle all of the database management for the application
### - Students
### - ResourceItems
### - Subjects 
################################################################################
class_name CMDatabaseUtilities
extends Node

enum GRADES {
	Preschool,
	Kindergarten,
	First_Grade,
	Second_Grade,
	Third_Grade,
	Fourth_Grade,
	Fifth_Grade,
	Sixth_Grade,
	Seventh_Grade,
	Eighth_Grade,
	Ninth_Grade,
	Tenth_Grade,
	Eleveneth_Grade,
	Twelfth_Grade
}

const USER_LIBRARY_PATH = "res://data/library.json"

## File path for the user settings 
const DATABASE_PATH = "/cm_database.tres"

## Base path for the user's folder
static var cm_database_path : String =  OS.get_user_data_dir()

static var is_mobile : bool = false


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
	

## Parses through JSON objects of ResourceItems and adds them to the database file
static func parse_json_data() -> void:
	var file_string = FileAccess.get_file_as_string(USER_LIBRARY_PATH)
	
	# Verify the contents
	if file_string.is_empty():
		print(FileAccess.get_open_error())
		return
	
	var json_data = JSON.parse_string(file_string)
	
	if json_data == null:
		print("Json data is null - aborting import")
		return 
		
	var json_library = json_data.Library
	var json_divisions = json_data.Divisions
		
	if json_library != null:
		var resource_item_count : int = 0
		for item in json_library:
			# Check to see if the title already exists in the database
			if does_resource_item_exist(item.TITLE):
				print(item.TITLE + " already exists")
				continue
			
			
			var resource : ResourceItem = ResourceItem.new()
			resource.title = item.TITLE
			resource.isbn = item.ISBN if item.ISBN != "NA" else ""
			resource.contributor_name = item.CONTRIBUTOR_NAME if item.CONTRIBUTOR_NAME != "NA" else ""
			resource.web_url = item.WEB_URL if item.WEB_URL != "NA" else ""
			resource.publisher = item.PUBLISHER if item.PUBLISHER != "NA" else ""
			resource.copyright_date = str(item.COPYRIGHT_DATE) if str(item.COPYRIGHT_DATE) != "NA" else null
			resource.year_written = str(item.YEAR_WRITTEN) if str(item.YEAR_WRITTEN) != "NA" else ""
			resource.number_of_pages = item.NUMBER_OF_PAGES if str(item.NUMBER_OF_PAGES) != "NA" else ""
			resource.edition = item.EDITION if item.EDITION != "NA" else ""
			resource.description = item.DESCRIPTION if item.DESCRIPTION != "NA" else ""
			
			if item.RESOURCE_TYPE != "NA":
				for r in ResourceData.ResourceType:
					if r == item.RESOURCE_TYPE:
						resource.resource_type = r
					
			if item.CONTRIBUTOR != "NA":
				for c in ResourceData.Contributors:
					if c == item.CONTRIBUTOR:
						resource.contributor = c
					pass
			
			if item.SUBJECT != "NA":
				for s in ResourceData.Subjects:
					if s == item.SUBJECT:
						resource.subject = s
					pass
			
			match item.DIVISION_TYPE:
				"None":
					resource.division_type = ResourceData.DivisionType
				"Assignment":
					resource.division_type = ResourceData.DivisionType.Assignment
				"Chapter":
					resource.division_type = ResourceData.DivisionType.Chapter
				"Lesson":
					resource.division_type = ResourceData.DivisionType.Lesson
				"Poem":
					resource.division_type = ResourceData.DivisionType.Poem
				_:
					resource.division_type = ResourceData.DivisionType.None
				
			if resource.division_type != ResourceData.DivisionType.None:
				for division in json_divisions:
					if division.TITLE == resource.title:
						var count : int = 0 
						for i in division.keys():
							if count > 1:
								resource.division_list.append(division[i])
							
							count += 1
				CMDatabaseUtilities.save_resource_item(resource)
	pass


## Returns the value for is_mobile
static func get_is_mobile() -> bool:
	return is_mobile


## Sets the value for is_mobile
static func set_is_mobile(value : bool) -> void:
	is_mobile = value
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
	var index = db.student_list.find(p_student)
	db.student_list.get(index).name = p_student.name
	db.student_list.get(index).grade = p_student.grade
	
	overwrite_database(db)
	pass
#endregion


#region ResourceItem functions
# TODO Need to add function to delete all assignments associated with the ResourceItem
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
	
	# Update all associated assignments
	db.subject_list = update_selected_resource_assignments(p_resource)
	
	overwrite_database(db)
	pass


## Removes the selected ResourceItem from the database
static func remove_resource_item(p_resource : ResourceItem) -> void:
	var db = get_database()
	var index = db.resource_list.find(p_resource)
	db.resource_list.remove_at(index)
	overwrite_database(db)
	pass


## Returns true if the ResourceItem exists else false
static func does_resource_item_exist(p_title : String) -> bool:
	var is_exist : bool = false
	
	var resource_list = get_all_resources()
	
	for item in resource_list:
		if item.title.to_lower() == p_title.to_lower():
			is_exist = true
			return is_exist
	
	return is_exist
#endregion


#region Subject and Assignment Functions
## Saves the subject to the database
static func add_subject(p_subject : Subject) -> void:
	var db = get_database()
	db.subject_list.append(p_subject)
	overwrite_database(db)
	pass


## Retrieve all the subjects in the database
static func get_subject_list() -> Array[Subject]:
	var db = get_database()
	return db.subject_list


## Removes the scheduled resource
static func remove_subject_from_schedule(p_subject : Subject) -> void:
	var db = get_database()
	var index = db.subject_list.find(p_subject)
	db.subject_list.remove_at(index)
	overwrite_database(db)
	pass


## Updates the selected assignment
static func update_assignment(p_assignment : Subject) -> void:
	var db = get_database()
	var index = db.subject_list.find(p_assignment)
	db.subject_list[index] = p_assignment
	overwrite_database(db)
	pass


## Removes all assignments associated with the selected ResourceItem
static func remove_selected_resource_assignments(p_resource : ResourceItem) -> void:
	var assignment_list : Array[Subject] = get_subject_list()
	
	for assignment in assignment_list:
		if assignment.resource == p_resource:
			remove_subject_from_schedule(assignment)
	pass


## Updates all assignments associated with the selected ResourceItem
static func update_selected_resource_assignments(p_resource : ResourceItem) -> Array[Subject]:
	var assignment_list : Array[Subject] = get_subject_list()

	for assignment in assignment_list:
		if assignment.resource == p_resource:
			if assignment.division_type != ResourceData.DivisionType.None:
				var new_assignment_list : Array[Assignment] = []
				for title in p_resource.division_list:
					var new_assignment : Assignment = Assignment.new()
					new_assignment.title = title
					new_assignment.progress = ResourceData.progress.Incomplete
					new_assignment_list.append(new_assignment)
				
				assignment.assignments = new_assignment_list
		else:
			assignment_list.append(assignment)
			
	return assignment_list
#endregion


#region Database functions
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
#endregion
