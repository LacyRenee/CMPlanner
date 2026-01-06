extends Control

## Access to the vbox to list all of the students in
@onready var v_box_students: VBoxContainer = %VBoxStudents

## Access to the list of subject options
@onready var option_button_subjects: OptionButton = %OptionButtonSubjects

## Access to the list of study methods
@onready var option_button_study_methods: OptionButton = %OptionButtonStudyMethods

## Calendar date picker popup
@onready var popup: Popup = $Panel/MarginContainer/VBoxContainer/PanelContainerStartDate/HBoxContainer/Popup

## Access to the button used to display the calendar popup
@onready var btn_todays_date: Button = %BtnTodaysDate

## Access to all available resources
@onready var item_list_resource: ItemList = %ItemListResource

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
	for student in student_list.students:
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

	margin_container.add_child(checkbox)
	v_box_students.add_child(margin_container)
	pass


func _on_button_pressed() -> void:
	#popup.show()
	pass 


## Searches through the list of resources
func _on_le_resource_text_changed(new_text: String) -> void:
	var search_value = new_text.to_lower()
	item_list_resource.clear()
	
	for i in range(item_list_resource_duplicate.get_item_count()):
		if item_list_resource_duplicate.get_item_text(i).to_lower().find(search_value) != -1:
			item_list_resource.add_item(item_list_resource_duplicate.get_item_text(i))
	pass
