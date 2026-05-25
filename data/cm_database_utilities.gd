################################################################################
### Utility class to handle all of the database management for the application
### - Students
### - ResourceItems
### - Subjects 
################################################################################
class_name CMDatabaseUtilities
extends Node

## List of all grades
enum GRADES {
	NA,
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

## Path to the custom user data to be imported
const USER_LIBRARY_PATH = "res://data/library.json"

## File path for the user settings 
const DATABASE_PATH = "/cm_database.tres"

## Base path for the user's folder
static var cm_database_path : String =  OS.get_user_data_dir()

## Toggles mobile settings
static var is_mobile : bool = false

## Active subjects
static var active_subjects : Array[ResourceData.Subjects] = []

## Calendar
static var _calendar : Calendar = Calendar.new()


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Create the application's database file
	if !get_database():
		var db : CMDatabase =  CMDatabase.new()
		
		# Family student required
		var family_student : Student = Student.new()
		family_student.name = "Family"
		family_student.grade = GRADES.NA
		family_student.is_active = true
		
		db.student_list.append(family_student)

		ResourceSaver.save(db, get_database_filepath())
		
	update_active_subjects()
	
	pass
	



#region Utility Functions
## Outlines the selected control in red
static func error_style_box_flat() -> StyleBoxFlat:
	var red_border = StyleBoxFlat.new()
	red_border.border_color = Color.RED
	red_border.border_width_bottom = 2
	red_border.border_width_left = 2
	red_border.border_width_right = 2
	red_border.border_width_top = 2
	return red_border


## The mathematical formula used to calculate the day of the week for any given date
static func zellers_congruence(day: int, month: int, year: int) -> Time.Weekday:
	if month < 3:
		month += 12
		year -= 1

	var q = day
	var m = month
	var K = year % 100
	var C = year / 100
	var h = (q + (13 * (m + 1)) / 5 + K + K / 4 + C / 4 - 2 * C) % 7
	
	# Adjusted Zeller's Congruence for Godot's Sunday = 0
	return (h + 6) % 7 as Time.Weekday


## Takes a string date and converts it into a calendar date
static func convert_string_to_date(p_string : String) -> Calendar.Date:
	var split_date = p_string.split("-")
	var year = int(split_date[0])
	var month = int(split_date[1])
	var day = int(split_date[2])
	
	var formatted_from_date : Calendar.Date = Calendar.Date.new(year, month, day)
	return formatted_from_date


## Formats a date as MM/DD/YYYY
static func get_formatted_date(p_date : Calendar.Date) -> String:
	var pattern : String = "%m-%d-%Y"
	var formatted_date = _calendar.get_date_formatted(p_date.year, p_date.month, p_date.day, pattern)
	return formatted_date


## Verifies the date format: MM-DD-YYYY
static func verify_date_format(p_date : String) -> bool:
	var regex_date_dash = RegEx.new()
	regex_date_dash.compile("^(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])-\\d{4}$")
	
	if regex_date_dash.search(p_date) != null:
		return true
	else:
		return false


## Strips the strings and compares them
static func compare_strings(p_string_one : String, p_string_two : String) -> bool:
	var result : bool 
	
	var formatted_string_one = p_string_one.replace("_", " ").to_lower().strip_edges()
	var formatted_string_two = p_string_two.replace("_", " ").to_lower().strip_edges()
	
	if formatted_string_one == formatted_string_two:
		result = true
	else:
		result = false
	
	return result


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
			resource.copyright_date = str(item.COPYRIGHT_DATE) if str(item.COPYRIGHT_DATE) != "NA" else "null"
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
#endregion


#region Mobile functions
## Returns the value for is_mobile
static func get_is_mobile() -> bool:
	return is_mobile


## Sets the value for is_mobile
static func set_is_mobile(value : bool) -> void:
	is_mobile = value
	pass
#endregion


#region Student functions
## Retrieves the list of students
static func get_student_list() -> Array[Student]:
	var db = get_database()
	return db.student_list


## Adds a student to the student list file
static func add_student(p_student : Student) -> void:
	var db = get_database()
	db.student_list.append(p_student)
	
	overwrite_database(db)
	pass


## Removes the selected student and all associated assignments from the database
static func remove_student(p_student : Student) -> void:
	var db = get_database()
	var assignment_list = db.subject_list
	var index = db.student_list.find(p_student)
	
	# Remove assignments associated with the student
	for assignment in assignment_list:
		if assignment.student == p_student:
			remove_subject_from_schedule(assignment)
	
	# Remove the student
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
	#db.subject_list = update_selected_resource_assignments(p_resource)
	
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


#region Subject Functions
## Retrieve all the subjects in the database
static func get_subject_list() -> Array[Subject]:
	var db = get_database()
	return db.subject_list


static func update_active_subjects() -> void:
	active_subjects.clear()
	var subject_list : Array[Subject] = get_subject_list()
	
	for subject in subject_list:
		if subject.is_finished == false:
			if not active_subjects.has(subject.subject):
				active_subjects.append(subject.subject)
	pass


## Saves the subject to the database
static func add_subject(p_subject : Subject) -> void:
	var db = get_database()
	db.subject_list.append(p_subject)
	overwrite_database(db)
	update_active_subjects()
	pass



## Removes the scheduled resource
static func remove_subject_from_schedule(p_subject : Subject) -> void:
	var db = get_database()
	var index = db.subject_list.find(p_subject)
	db.subject_list.remove_at(index)
	overwrite_database(db)
	update_active_subjects()
	pass


## Updates the selected subject
static func update_subject(p_subject : Subject) -> void:
	var db = get_database()
	var index = db.subject_list.find(p_subject)
	
	db.subject_list[index] = p_subject
	overwrite_database(db)
	update_active_subjects()
	pass


## Removes all subjects associated with the selected ResourceItem
static func remove_selected_resource_subjects(p_resource : ResourceItem) -> void:
	var subject_list : Array[Subject] = get_subject_list()
	
	for subject in subject_list:
		if subject.resource == p_resource:
			remove_subject_from_schedule(subject)
	
	update_active_subjects()
	pass


## Updates all assignments associated with the selected ResourceItem
static func update_selected_resource_assignments(p_resource : ResourceItem) -> void:
	var db = get_database()
	var subject_list : Array[Subject] = get_subject_list()

	for subject in subject_list:
		if subject.resource == p_resource:
			if subject.division_type == ResourceData.DivisionType.None:
				pass
			else:
				subject.assignments.clear()
				for assignment in p_resource.division_list:
					var new_assignment : Assignment = Assignment.new()
					new_assignment.title = assignment
					new_assignment.progress = ResourceData.progress.Incomplete
					subject.assignments.append(new_assignment)
	
	db.subject_list = subject_list
	overwrite_database(db)
	update_active_subjects()
	pass
#endregion


#region Assignment Functions
## Save the daily assignment note
static func save_daily_note(p_note : String, p_date : String) -> void:
	var db = get_database()

	# Update the daily note if it exists
	for i in db.daily_notes.size():
		if compare_strings(db.daily_notes[i].date, p_date):
			db.daily_notes[i].notes = p_note
			overwrite_database(db)
			return
	
	# Create a daily note if it does not exist
	var new_daily_note : DailyNotes = DailyNotes.new()
	new_daily_note.date = p_date
	new_daily_note.notes = p_note

	
	db.daily_notes.append(new_daily_note)
	overwrite_database(db)
	pass


## Retrieves a selected daily note
static func get_daily_note(p_date : String) -> DailyNotes:
	var db = get_database()
	var note_list : Array[DailyNotes] = db.daily_notes

	for i in note_list.size():
		if note_list[i].date == p_date:
			return note_list[i]
	return null


## Retrieves all of the daily notes
static func get_daily_note_list() -> Array[DailyNotes]:
	var db = get_database()
	return db.daily_notes


## Save the note for the selected assignment
static func save_assignment_note(p_subject : Subject, p_assignment : Assignment, p_note : String) -> void:
	var db = get_database()
	
	if p_subject.assignments.is_empty():
		pass
	else:
		var assignment_index = p_subject.assignments.find(p_assignment)
		p_subject.assignments[assignment_index].notes = p_note
	
	var subject_index = db.subject_list.find(p_subject)
	db.subject_list[subject_index] = p_subject
	
	overwrite_database(db)
	pass 


## Save the start date for the selected assignment
static func save_assignment_start_date(p_subject : Subject, p_assignment : Assignment, p_start_date : String) -> void:
	var db = get_database()
	
	var assignment_index = p_subject.assignments.find(p_assignment)
	p_subject.assignments[assignment_index].start_date = p_start_date
	
	var subject_index = db.subject_list.find(p_subject)
	db.subject_list[subject_index] = p_subject
	
	overwrite_database(db)
	pass


## Save the assignment progress
static func save_assignment_progress(p_subject : Subject, p_assignment : Assignment, p_index : int) -> void:
	var db = get_database()
	var assignment_index = p_subject.assignments.find(p_assignment)
	
	p_subject.assignments[assignment_index].progress = p_index as ResourceData.progress

	# Save the completed date or finsihed complete date based on the progress
	if p_index == ResourceData.progress.Complete_and_finish:
		p_subject.assignments[assignment_index].completed_date = get_formatted_date(_calendar.Date.today())
		p_subject.is_finished =  true
	elif p_index == ResourceData.progress.Completed and p_subject.resource.division_type == ResourceData.DivisionType.None or\
		 p_index == ResourceData.progress.Omit_assignment and p_subject.resource.division_type == ResourceData.DivisionType.None:
		p_subject.assignments[assignment_index].completed_date = get_formatted_date(_calendar.Date.today())
		
		var new_assignment : Assignment = Assignment.new()
		new_assignment.title = p_subject.resource.title
		new_assignment.progress = ResourceData.progress.Incomplete
		new_assignment.completed_date = "NA"
		p_subject.assignments.append(new_assignment)
	elif p_index == ResourceData.progress.Completed or p_index == ResourceData.progress.Omit_assignment:
		p_subject.assignments[assignment_index].completed_date = get_formatted_date(_calendar.Date.today())
		
		if  p_subject.division_type != ResourceData.DivisionType.None and\
			assignment_index == p_subject.assignments.size() - 1:
			p_subject.is_finished =  true
		else:
			p_subject.is_finished =  false
	else:
		p_subject.assignments[assignment_index].completed_date = ""
		p_subject.is_finished =  false

	
	var subject_index = db.subject_list.find(p_subject)
	db.subject_list[subject_index] = p_subject
	
	overwrite_database(db)
	pass
#endregion


#region Report functions
## Create a summary of what assignments have been finished
static func generate_report(p_student : Student, p_date_from : String, p_date_to : String, p_subjects : Array[ResourceData.Subjects]) -> String:
	var subject_list : Array[Subject] = get_subject_list()
	var report_data : Array[Dictionary] = []
	var date_from : Calendar.Date = convert_string_to_date(p_date_from)
	var date_to : Calendar.Date = convert_string_to_date(p_date_to)
	
	# Parse out the data for the selected Student and Subjects and date	
	for i in subject_list.size():	
		if subject_list[i].student == p_student and\
		   p_subjects.has(subject_list[i].subject):
			
			if !subject_list[i].start_date.is_empty():
				
				var assignment_start_date : Calendar.Date = convert_string_to_date(subject_list[i].start_date)
				
				if (assignment_start_date.is_equal(date_from) or assignment_start_date.is_after(date_from)) and\
				   (assignment_start_date.is_equal(date_to) or assignment_start_date.is_before(date_to)):
					var data = create_report_row(subject_list[i])
					
					report_data.append(data)
			else:
				var assignment_start_after_start_date : Calendar.Date = convert_string_to_date(subject_list[i].start_after.start_date)
				
				if (assignment_start_after_start_date.is_equal(date_from) or assignment_start_after_start_date.is_after(date_from)) and\
				   (assignment_start_after_start_date.is_equal(date_to) or assignment_start_after_start_date.is_before(date_to)):
					var data = create_report_row(subject_list[i])
					
					report_data.append(data)
	
	if !report_data.is_empty():
		var filename = save_progress_report(p_student, report_data)
		return filename
	else:
		return ""


## Creates a row of data for the Progress Report
static func create_report_row(p_subject : Subject) -> Dictionary:
	var student_key = "student"
	var student_value = p_subject.student.name
	
	var subject_key : String = "subject"
	var subject_value : String = ResourceData.Subjects.keys()[p_subject.subject]
	
	var resource_key : String = "resource_title"
	var resource_value : String = p_subject.resource.title
	
	var assignment_title_key : String = "assignment"
	var assignment_title_value : Array[String] = []
	
	var completed_date_key : String = "completed_date"
	var completed_date_value : Array[String] = []
	
	var notes_key : String = "notes"
	var notes_value : Array[String] = []
	
	var daily_notes_key : String = "daily_notes"
	var daily_notes_value : String = ""
	
	# List of all daily notes
	var daily_notes : Array[DailyNotes] = get_daily_note_list()
	
	# Add the assignment, dates, and notes into their nested arrays
	for a in p_subject.assignments.size():
		assignment_title_value.append(p_subject.assignments[a].title if !p_subject.assignments[a].title.is_empty() else "NA")
		completed_date_value.append(p_subject.assignments[a].completed_date if !p_subject.assignments[a].completed_date.is_empty() else "NA")
		notes_value.append(p_subject.assignments[a].notes if !p_subject.assignments[a].notes.is_empty() else "NA")
		
		# Find any daily notes for the assignment
		
		for n in daily_notes.size():
			if !p_subject.assignments[a].completed_date.is_empty():
				var daily_note_date : Calendar.Date = convert_string_to_date(daily_notes[n].date)
				var assignment_completed_date : Calendar.Date = convert_string_to_date(p_subject.assignments[a].completed_date)
				
				if daily_note_date.is_equal(assignment_completed_date):
					daily_notes_value = daily_notes[n].notes
				else:
					daily_notes_value = "NA"
	
	# create the data object
	var data : Dictionary = {
		student_key: student_value,
		subject_key: subject_value,
		resource_key: resource_value,
		assignment_title_key: assignment_title_value,
		completed_date_key: completed_date_value,
		notes_key: notes_value,
		daily_notes_key: daily_notes_value
	}
	return data


static func find_note_by_date() -> void:
	pass

## Saves the Progress report to the user's Desktop
static func save_progress_report(p_student : Student, p_report_data : Array[Dictionary]) -> String:
	# Create the file
	var filename = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/" + p_student.name + "_report.csv"
	var file = FileAccess.open(filename, FileAccess.WRITE)
	
	if file == null: 
		return ""
		
	# Table headers
	var headers = ["student", "subject", "resource_title", "assignment", "completed_date", "notes", "daily_notes"]
	file.store_csv_line(headers)
	
	for record in p_report_data:
		for assignment_count in record.assignment.size():
			var row = []
			
			if assignment_count == 0:
				row.append(record.student)
				row.append(record.subject)
				row.append(record.resource_title)
			else: # Append for student, subject, and resource_title
				row.append("-")
				row.append("-")
				row.append("-")
			
			row.append(record.assignment[assignment_count])
			
			row.append(record.completed_date[assignment_count])
			
			row.append(record.notes[assignment_count])
			
			if record.completed_date[assignment_count] != "NA":
				row.append(record.daily_notes)
			
			file.store_csv_line(row)
	
	# Save and close the file
	file.close()
	return filename

#endregion


#region Memorize Set Functions
## Saves a new memorize set to the database
static func save_set(p_set : Set) -> void:
	var db = get_database()
	db.memorize_sets.append(p_set)
	overwrite_database(db)
	pass


## Retrieves all the memorize sets
static func get_all_memorize_sets() -> Array[Set]:
	var db = get_database()
	return db.memorize_sets
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
