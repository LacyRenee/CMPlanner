################################################################################
### ResourceScheduler
## Allows a ResourceItem to be scheduled for students
## ResourceItems with a DivisionType that is not NONE will have assignments
## automatically created for them
################################################################################
extends Control
## Access to the Student container for error checking
@onready var panel_container_assign_students: PanelContainer = %PanelContainerAssignStudents

## Access to the week days container for error checking
@onready var panel_container_use_on: PanelContainer = %PanelContainerUseOn

## Access to the vbox to list all of the students in
@onready var v_box_students: VBoxContainer = %VBoxStudents

## Access to the list of subject options
@onready var option_button_subjects: OptionButton = %OptionButtonSubjects

## Access to the list of study methods
@onready var option_button_study_methods: OptionButton = %OptionButtonStudyMethods

## Calendar date picker popup
@onready var popup_calendar: Popup = %PopupCalendar

## Access to the button used to display the calendar popup
@onready var btn_todays_date: Button = %BtnTodaysDate

## Access to all available resources
@onready var item_list_resource: ItemList = %ItemListResource

## Access to the update button
@onready var btn_update_schedule: Button = %BtnUpdateSchedule

## Access to the save button
@onready var btn_save_schedule: Button = %BtnSaveSchedule

@onready var item_list_students: ItemList = %ItemListStudents

## defined error number for missing a resource
const ERROR_MISSING_RESOURCE : int = 1

## defined error number for missing student(s)
const ERROR_MISSING_STUDENT : int = 2

## defined error number for missing week days
const ERROR_MISSING_WEEK_DAYS : int = 3

## Holds the resource item list backup
## Used when filtering the resource list
var item_list_resource_duplicate : ItemList = ItemList.new()

## Users selected view (e.g., New, Edit, etc...)
var view_option : ResourceData.ViewingOptions

var is_mobile : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("mobile"):
		is_mobile = true
	
	# Set the View to "New"
	update_view_option(ResourceData.ViewingOptions.New)
	
	# Add today's date to the date label
	btn_todays_date.text = str(Calendar.Date.today())
	
	# Populate all the resources
	var resource_list : Array[ResourceItem] = CMDatabaseUtilities.get_all_resources()
	for r in resource_list:
		var index = item_list_resource.add_item(r.title)
		item_list_resource.set_item_metadata(index, r)
		
		var index_duplicate = item_list_resource_duplicate.add_item(r.title)
		item_list_resource_duplicate.set_item_metadata(index_duplicate, r)
	
	# Add all students
	var student_list = CMDatabaseUtilities.get_student_list()
	
	if is_mobile:
		item_list_students.max_columns = 1
		
	for student in student_list:
		var index = item_list_students.add_item(student.name)
		item_list_students.set_item_metadata(index, student)
	
	## Populate the subject options
	for subject in ResourceData.Subjects:
		option_button_subjects.add_item(subject)
	
	# Populate the study method options
	for method in ResourceData.study_method:
		option_button_study_methods.add_item(method.replace("_", " "))
	
	#region Signals
	# Connects to the selected date for the start date 
	SignalBus.connect("date_selected", set_selected_date, 0)
	
	## Connects to the selected resource schedule it 
	SignalBus.connect("schedule_selected_resource", set_selected_resource, 0)
	
	## Connects to the assignment to be edited
	SignalBus.connect("edit_selected_assignment", display_selected_assignment, 0)
	#endregion
	pass 


## Displays an assignment for editing purposes
func display_selected_assignment(p_assignment : Subject) -> void:	
	# Update the view
	update_view_option(ResourceData.ViewingOptions.Edit)
	
	# Selected the current resource
	set_selected_resource(p_assignment.resource)
	
	option_button_subjects.selected = p_assignment.subject
	option_button_study_methods.selected = p_assignment.study_method
	btn_todays_date.text = p_assignment.start_date
	
	# Check selected student
	for index in range(item_list_students.get_item_count()):
		var student = item_list_students.get_item_metadata(index)
		if student == p_assignment.student:
			item_list_students.select(index)
	
	# Check selected days
	var week_days = get_tree().get_nodes_in_group("day_selected")
	
	for day in p_assignment.week_days:
		for d in week_days:
			if d.name.contains(ResourceData.week_day.keys()[day]):
				d.button_pressed = true
	pass


## Updates which view the user is in (e.g., edit, view, etc)
func update_view_option(p_option) -> void:
	view_option = p_option
	update_view()
	pass


## Toggles the necessary UI nodes depending on the view
func update_view() -> void:
	match view_option:
		ResourceData.ViewingOptions.New:
			btn_save_schedule.visible = true
			btn_update_schedule.visible = false
		ResourceData.ViewingOptions.Edit:
			btn_save_schedule.visible = false
			btn_update_schedule.visible = true
		ResourceData.ViewingOptions.View:
			pass
	pass


## Selects the resourceitem that was sent from the resource page
func set_selected_resource(p_resource : ResourceItem) -> void:
	for i in range(item_list_resource.get_item_count()):
		if item_list_resource.get_item_text(i).to_lower().find(p_resource.title.to_lower()) != -1:
			item_list_resource.select(i)
	pass


## Sets calendar picker date to today
func set_selected_date(p_date) -> void:
	btn_todays_date.text = str(p_date)
	pass


## Creates an assignment for each division item for the ResourceItem
## Marks each division item as "Incomplete"
func create_assignments(p_resource : ResourceItem) -> Array[Assignment]:
	var assignment_list : Array[Assignment] = []
	
	for title in p_resource.division_list:
		var assignment : Assignment = Assignment.new()
		assignment.title = title
		assignment.progress = ResourceData.progress.Incomplete
		assignment_list.append(assignment)
	
	return assignment_list


## Goes through each editable node and verifies that each required field is
## filled out
func error_check_form() -> Array[int]:
	# Number os errors in the form
	var errors : Array[int] = []
	
	if item_list_resource.get_selected_items().is_empty():
		errors.append(ERROR_MISSING_RESOURCE)
	
	# Error check the form to ensure there's a student
	var checked_students = item_list_students.get_selected_items()
	if checked_students.is_empty():
		errors.append(ERROR_MISSING_STUDENT)
	
	# Error check the form to ensure there is a weekday selected 
	var checked_days = get_tree().get_nodes_in_group("day_selected")
	var checked_days_count : int = 0
	
	for checkbox in checked_days:
		if checkbox.is_pressed():
			checked_days_count += 1
	
	if checked_days_count == 0:
		errors.append(ERROR_MISSING_WEEK_DAYS)
	
	return errors


## Displays to the user what fields must be filled out
func add_error_formats(p_errors) -> void:
	var red_border : StyleBoxFlat = StyleBoxFlat.new()
	red_border.border_color = Color.RED
	red_border.border_width_bottom = 2
	red_border.border_width_left = 2
	red_border.border_width_right = 2
	red_border.border_width_top = 2
	
	for error in p_errors:
		match error:
			ERROR_MISSING_RESOURCE:
				item_list_resource.add_theme_stylebox_override("panel", red_border)
			ERROR_MISSING_STUDENT:
				panel_container_assign_students.add_theme_stylebox_override("panel", red_border)
			ERROR_MISSING_WEEK_DAYS:
				panel_container_use_on.add_theme_stylebox_override("panel", red_border)
	pass


## Removes the error themes from the required fields
func remove_error_formats() -> void:
	item_list_resource.remove_theme_stylebox_override("panel")
	panel_container_assign_students.remove_theme_stylebox_override("panel")
	panel_container_use_on.remove_theme_stylebox_override("panel")
	pass


## Saves the information for the selected assignment
func save_data() -> Subject:
	var new_subject : Subject = Subject.new()
	
	# Add the selected resource
	new_subject.resource = item_list_resource.get_item_metadata(0)
	
	## Create the assignments if the ResourceItem has a division type
	if new_subject.resource.division_type != ResourceData.DivisionType.None:
		new_subject.division_type = new_subject.resource.division_type
		new_subject.assignments = create_assignments(new_subject.resource)
	
	new_subject.subject = option_button_subjects.selected
	new_subject.study_method = option_button_study_methods.selected
	new_subject.start_date = btn_todays_date.text
	
	# Add the week days
	var selected_days = get_tree().get_nodes_in_group("day_selected")
	for day in selected_days:
		if day.is_pressed() == true:
			match  day.text:
				"Sun":
					new_subject.week_days.append(ResourceData.week_day.Sunday)
				"Mon":
					new_subject.week_days.append(ResourceData.week_day.Monday)
				"Tue":
					new_subject.week_days.append(ResourceData.week_day.Tuesday)
				"Wed":
					new_subject.week_days.append(ResourceData.week_day.Wednesday)
				"Thu":
					new_subject.week_days.append(ResourceData.week_day.Thursday)
				"Fri":
					new_subject.week_days.append(ResourceData.week_day.Friday)
				"Sat":
					new_subject.week_days.append(ResourceData.week_day.Saturday)
	
	return new_subject


## Displays the popup calendar date picker
func _on_button_pressed() -> void:
	popup_calendar.show()
	pass 


## Saves the scheduled subject
func _on_btn_save_schedule_pressed() -> void:
	# Remove any prior themes
	remove_error_formats()
	
	## Error check the form for required fields
	var errors = error_check_form()
	if !errors.is_empty():
		add_error_formats(errors)
		return
	
	# Need to save the resource for each student selected 
		# Add the students
	var student_list = CMDatabaseUtilities.get_student_list()
	var selected_students = item_list_students.get_selected_items()
	
	for index in selected_students:
		# Create the new subject and add all the data
		var new_subject : Subject = save_data()
		
		# Add the student 
		new_subject.student = item_list_students.get_item_metadata(index)
		
		## Save the resource to the database
		CMDatabaseUtilities.add_subject(new_subject)
		
	SignalBus.display_schedule_page.emit()
	pass 


## Incrementally searches through the resource item lists, 
## and selects the searched for ResourceItem
func _on_le_search_resource_text_changed(new_text: String) -> void:
	var search_value = new_text.to_lower()
	item_list_resource.clear()
	
	for i in range(item_list_resource_duplicate.get_item_count()):
		if item_list_resource_duplicate.get_item_text(i).to_lower().find(search_value) != -1:
			var index = item_list_resource.add_item(item_list_resource_duplicate.get_item_metadata(i).title)
			item_list_resource.set_item_metadata(index, item_list_resource_duplicate.get_item_metadata(i))
			item_list_resource.select(index)
	pass


## Goes back to the Schedule page view
func _on_btn_cancel_schedule_pressed() -> void:
	SignalBus.display_schedule_page.emit()
	pass 


func _on_btn_update_schedule_pressed() -> void:
	# Remove any prior themes
	remove_error_formats()
	
	## Error check the form for required fields
	var errors = error_check_form()
	if !errors.is_empty():
		add_error_formats(errors)
		return
	
	# Check to see if one student is selected or multiple
	# If multiple students are selected, the db will need to be searched 
	# to see if an assignment is already created for the selected student AND 
	# resource. If there is no assignment created for the student, a new 
	# assignment will be created
	var selected_student_list = item_list_students.get_selected_items()
	
	if selected_student_list.size() > 1:
		for index in selected_student_list:
			var assignment_list = CMDatabaseUtilities.get_subject_list()
			for assignment in assignment_list:
				var new_subject : Subject = save_data()
				new_subject.student = item_list_students.get_item_metadata(index)
				
				# Student assignment found! Update it
				if assignment.student == item_list_students.get_item_metadata(index):
					CMDatabaseUtilities.update_subject(new_subject)
				else:
					CMDatabaseUtilities.add_subject(new_subject)
			pass
	else:
		var new_subject : Subject = save_data()
		new_subject.student = item_list_students.get_item_metadata(0)
		CMDatabaseUtilities.update_subject(new_subject)
		
		SignalBus.display_schedule_page.emit()
	pass
