################################################################################
### ResourceScheduler
################################################################################
extends Control
@onready var lbl_info: Label = %LblInfo



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
@onready var popup_calendar: Popup = $Panel/MarginContainer/VBoxContainer/PanelContainerStartDate/HBoxContainer/Popup

## Access to the button used to display the calendar popup
@onready var btn_todays_date: Button = %BtnTodaysDate

## Access to all available resources
@onready var item_list_resource: ItemList = %ItemListResource



## defined error number for missing a resource
const ERROR_MISSING_RESOURCE : int = 1

## defined error number for missing student(s)
const ERROR_MISSING_STUDENT : int = 2

## defined error number for missing week days
const ERROR_MISSING_WEEK_DAYS : int = 3

## Holds the resource item list backup
var item_list_resource_duplicate : ItemList = ItemList.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add today's date to the date label
	btn_todays_date.text = str(Calendar.Date.today())
	
	# Populate all the resources
	var resource_list = CMDatabaseUtilities.get_all_resources()
	for file in resource_list.get_files():
		var resource = load(resource_list.get_current_dir() + "/" + file)
		var index = item_list_resource.add_item(resource.title)
		item_list_resource.set_item_metadata(index, resource)
		
		var index_duplicate = item_list_resource_duplicate.add_item(resource.title)
		item_list_resource_duplicate.set_item_metadata(index_duplicate, resource)
	
	# Add all students
	var student_list = CMDatabaseUtilities.get_student_list()
	for student in student_list:
		create_student_checkbox(student.name)
	
	## Populate the subject options
	for subject in ResourceData.Subjects:
		option_button_subjects.add_item(subject)
	
	# Populate the study method options
	for method in ResourceData.study_method:
		option_button_study_methods.add_item(method.replace("_", " "))
	
	# Connects to the selected date for the start date 
	SignalBus.connect("date_selected", set_selected_date, 0)
	
	pass 


func set_selected_date(p_date) -> void:
	btn_todays_date.text = str(p_date)
	pass


## Creates a checkbox for each student
func create_student_checkbox(p_name) -> void:
	var margin_container : MarginContainer = MarginContainer.new()
	
	var checkbox : CheckBox = CheckBox.new()
	checkbox.text = p_name
	checkbox.custom_minimum_size = Vector2(100,10)
	checkbox.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	checkbox.add_to_group("student_selected", true)
	

	margin_container.add_child(checkbox)
	v_box_students.add_child(margin_container)
	pass


## Creates an assignment for each division item for the ResourceItem
## Marks each division item as "Incomplete"
func create_assignments(resource : ResourceItem) -> Dictionary:
	var dictionary : Dictionary
	
	for item in resource.division_list:
		var entry = {
			Title = item,
			Progress = ResourceData.progress.Incomplete
		}
		dictionary["assignment"] = entry
	
	return dictionary


## Goes through each editable node and verifies that each required field is
## filled out
func error_check_form() -> void:
	# Error check form to make sure there's a resource
	var errors : Array[int] = []
	if item_list_resource.get_selected_items().is_empty():
		errors.append(ERROR_MISSING_RESOURCE)
	
	# Error check the form to ensure there's a student 
	var checked_students = get_tree().get_nodes_in_group("student_selected")
	var checked_students_count : int = 0
	
	for checkbox in checked_students:
		if checkbox.is_pressed():
			checked_students_count += 1
	
	if checked_students_count == 0:
		errors.append(ERROR_MISSING_STUDENT)
	
	# Error check the form to ensure there is a weekday selected 
	var checked_days = get_tree().get_nodes_in_group("day_selected")
	var checked_days_count : int = 0
	
	for checkbox in checked_days:
		if checkbox.is_pressed():
			checked_days_count += 1
	
	if checked_days_count == 0:
		errors.append(ERROR_MISSING_WEEK_DAYS)
	
	if errors.size() > 0:
		add_error_formats(errors)
		return
	pass


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


## Displays the popup calendar date picker
func _on_button_pressed() -> void:
	popup_calendar.show()
	pass 


func display_info(text) -> void:
	lbl_info.text = str(text)
	pass


## Saves the scheduled subject
func _on_btn_save_schedule_pressed() -> void:
	# Remove any prior themes
	remove_error_formats()
	
	## Error check the form for required fields
	error_check_form()
	
	## Create the new subject and add all the data
	var new_subject : Subject = Subject.new()
	
	# Add the selected resource
	new_subject.resource = item_list_resource.get_item_metadata(0)
	
	# Add the subject
	new_subject.subject = option_button_subjects.selected
	
	# Add the students
	var student_list = CMDatabaseUtilities.get_student_list()
	var selected_students = get_tree().get_nodes_in_group("student_selected")
	
	for selected in selected_students:
		if selected.is_pressed() == true:
			for student in student_list.students:
				if student.name == selected.text:
					new_subject.student.append(student)
	
	# Add the study method
	new_subject.study_method = option_button_study_methods.selected
	
	# Add the week days
	var selected_days = get_tree().get_nodes_in_group("day_selected")
	
	for selected in selected_days:
		if selected.is_pressed() == true:
			new_subject.week_day.append(selected.text)
	
	## Add the start date
	new_subject.start_date = btn_todays_date.text
	
	## Create the assignments if the ResourceItem has a division type
	if new_subject.resource.division_type != ResourceData.DivisionType.None:
		var assignments = create_assignments(new_subject.resource)
		new_subject.assignments = assignments
	
	## Save the resource to the database
	pass 


## Searches through the resource item lists, and selects the searched for
## ResourceItem
func _on_le_search_resource_text_changed(new_text: String) -> void:
	var search_value = new_text.to_lower()
	item_list_resource.clear()
	
	for i in range(item_list_resource_duplicate.get_item_count()):
		if item_list_resource_duplicate.get_item_text(i).to_lower().find(search_value) != -1:
			var index = item_list_resource.add_item(item_list_resource_duplicate.get_item_metadata(i).title)
			item_list_resource.set_item_metadata(index, item_list_resource_duplicate.get_item_metadata(i))
			item_list_resource.select(index)
			print(item_list_resource.is_selected(index))
	pass
