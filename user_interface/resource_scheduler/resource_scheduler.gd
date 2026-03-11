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

## Access to the list of students 
@onready var options_student_list: OptionButton = %OptionsStudentList

## Access to the resource options
@onready var options_resources: OptionButton = %OptionsResources

## Access to the checkbox for the start date
@onready var check_start_date: CheckBox = %CheckStartDate

## Access to the checkbox for the start after
@onready var check_start_after: CheckBox = %CheckStartAfter

## Access to the panel container for the start after
@onready var panel_container_start_after: PanelContainer = %PanelContainerStartAfter


## Defined error number for missing a resource
const ERROR_MISSING_RESOURCE : int = 1

## Defined error number for missing student(s)
const ERROR_MISSING_STUDENT : int = 2

## Defined error number for missing week days
const ERROR_MISSING_WEEK_DAYS : int = 3


## Holds the resource item list backup
## Used when filtering the resource list
var item_list_resource_duplicate : ItemList = ItemList.new()

## Users selected view (e.g., New, Edit, etc...)
var view_option : ResourceData.ViewingOptions

## Detetmines which layout to load
var is_mobile : bool = false

## References the Subject to be updated
var updated_subject : Subject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("mobile"):
		is_mobile = true
	
	
	# Set the View to "New"
	update_view_option(ResourceData.ViewingOptions.New)
	
	# Add today's date to the date label
	btn_todays_date.text = CMDatabaseUtilities.get_formatted_date(Calendar.Date.today())
	
	# Add all the students to the dropdown
	populate_student_list()
	
	# Add all the resources to the ItemList
	populate_resource_list()
	
	# Display start after options if any subjects have been assigned
	var subject_list = CMDatabaseUtilities.get_subject_list()
	if !subject_list.is_empty():
		panel_container_start_after.visible = true
		
		for r in subject_list.size():
			options_resources.add_item(subject_list[r].resource.title)
			options_resources.set_item_metadata(r, subject_list[r])
		
		options_resources.selected = -1
	
	
	## Populate the subject options
	for subject in ResourceData.Subjects:
		option_button_subjects.add_item(subject.replace("_", " "))
		
	
	
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


## Adds all of the active students to the drop down list
func populate_student_list() -> void:
	var student_list : Array[Student] = CMDatabaseUtilities.get_student_list()
	for i in student_list.size():
		options_student_list.add_item(student_list[i].name)
		options_student_list.set_item_metadata(i, student_list[i])
	pass


## Adds all of the resources to the itemlist
func populate_resource_list() -> void:
	var resource_list : Array[ResourceItem] = CMDatabaseUtilities.get_all_resources()
	for r in resource_list.size():
		var index = item_list_resource.add_item(resource_list[r].title)
		item_list_resource.set_item_metadata(index, resource_list[r])
		
		var index_duplicate = item_list_resource_duplicate.add_item(resource_list[r].title)
		item_list_resource_duplicate.set_item_metadata(index_duplicate, r)
	pass


## Displays an assignment for editing purposes
func display_selected_assignment(p_assignment : Subject) -> void:
	updated_subject = p_assignment
	
	# Update the view
	update_view_option(ResourceData.ViewingOptions.Edit)
	
	# Selected the current resource
	set_selected_resource(p_assignment.resource)
	
	# Set the subject
	option_button_subjects.selected = p_assignment.subject
	
	# Set the study method
	option_button_study_methods.selected = p_assignment.study_method
	
	# Set the start date
	btn_todays_date.text = p_assignment.start_date
	
	# Set the selected student
	for i in options_student_list.get_item_count():
		if options_student_list.get_item_metadata(i) == p_assignment.student:
			options_student_list.select(i)
	
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


## Selects the ResourceItem that was sent from the resource page
func set_selected_resource(p_resource : ResourceItem) -> void:
	for i in range(item_list_resource.get_item_count()):
		if item_list_resource.get_item_text(i).to_lower().find(p_resource.title.to_lower()) != -1:
			item_list_resource.select(i)
	pass


## Sets calendar picker date to today
func set_selected_date(p_date) -> void:
	btn_todays_date.text = CMDatabaseUtilities.get_formatted_date(p_date)
	pass


## Creates an assignment for each division item for the ResourceItem
## Marks each division item as "Incomplete"
func create_assignments(p_resource : ResourceItem) -> Array[Assignment]:
	var assignment_list : Array[Assignment] = []
	
	if p_resource.division_type == ResourceData.DivisionType.None:
		var new_assignment : Assignment = Assignment.new()
		new_assignment.title = p_resource.title
		new_assignment.progress = ResourceData.progress.Incomplete
		assignment_list.append(new_assignment)
	else:
		for title in p_resource.division_list:
			var new_assignment : Assignment = Assignment.new()
			new_assignment.title = title
			new_assignment.progress = ResourceData.progress.Incomplete
			assignment_list.append(new_assignment)
	
	return assignment_list


## Goes through each editable node and verifies that each required field is
## filled out
func error_check_form() -> Array[int]:
	# Number os errors in the form
	var errors : Array[int] = []
	
	if item_list_resource.get_selected_items().is_empty():
		errors.append(ERROR_MISSING_RESOURCE)
	
	# Error check the form to ensure there's a student
	if options_student_list.selected == -1:
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
func save_data(p_new_subject : Subject) -> Subject:
	# Add the selected resource
	p_new_subject.resource = item_list_resource.get_item_metadata(item_list_resource.get_selected_items()[0])
	
	# Add the division type
	p_new_subject.division_type = p_new_subject.resource.division_type
	
	# Create the assignments for the subject
	p_new_subject.assignments = create_assignments(p_new_subject.resource)
	
	# Add the student
	p_new_subject.student = options_student_list.get_item_metadata(options_student_list.selected)
		
	# Add the subject
	p_new_subject.subject = ResourceData.Subjects.values()[option_button_subjects.selected]
	
	# Add the study method
	p_new_subject.study_method = option_button_study_methods.selected
	
	# Add either the start date or start after ResourceItem 
	if check_start_date.button_pressed == true:
		p_new_subject.start_date = btn_todays_date.text
	else:
		var index = options_resources.selected
		p_new_subject.start_after = options_resources.get_item_metadata(index)
	
	# Add the week days
	var selected_days = get_tree().get_nodes_in_group("day_selected")
	for day in selected_days:
		if day.is_pressed() == true:
			match day.text:
				"Sun":
					p_new_subject.week_days.append(ResourceData.week_day.Sunday)
				"Mon":
					p_new_subject.week_days.append(ResourceData.week_day.Monday)
				"Tue":
					p_new_subject.week_days.append(ResourceData.week_day.Tuesday)
				"Wed":
					p_new_subject.week_days.append(ResourceData.week_day.Wednesday)
				"Thu":
					p_new_subject.week_days.append(ResourceData.week_day.Thursday)
				"Fri":
					p_new_subject.week_days.append(ResourceData.week_day.Friday)
				"Sat":
					p_new_subject.week_days.append(ResourceData.week_day.Saturday)
	return p_new_subject


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
	
	# Create the new subject and add all the data
	var new_subject : Subject = Subject.new()
	save_data(new_subject)
	
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
	
	# Verify that the assignment already exists
	var assignment_list = CMDatabaseUtilities.get_subject_list()
	for assignment in assignment_list:
		updated_subject.week_days.clear()
		save_data(updated_subject)
		
		# Student assignment found! Update it
		if assignment.student == updated_subject.student and assignment.resource == updated_subject.resource:
			CMDatabaseUtilities.update_subject(updated_subject)
		else:
			CMDatabaseUtilities.add_subject(updated_subject)
	
	
	SignalBus.display_schedule_page.emit()
	pass


## Toggles the OptionButton for the ResourceItems
func _on_check_start_after_pressed() -> void:
	check_start_after.button_pressed = true
	options_resources.disabled = false
	
	check_start_date.button_pressed = false
	btn_todays_date.disabled = true
	pass


## Toggles the date picker
func _on_check_start_date_pressed() -> void:
	check_start_after.button_pressed = false
	options_resources.disabled = true
	options_resources.selected = -1
	
	check_start_date.button_pressed = true
	btn_todays_date.disabled = false
	pass


func _on_options_resources_item_selected(index: int) -> void:
	pass # Replace with function body.
