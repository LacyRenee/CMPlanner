################################################################################
### Settings Page
### Allows for student creation and deletion
### Allows for report generation: Assignments, attendance, and bibliographies
################################################################################
extends Control

#region student variables
## Access to the new student's name
@onready var popup_le_name: LineEdit = %PopupLeName

## Access to the grade options
@onready var option_grade: OptionButton = %OptionGrade

## Access to the student table
@onready var student_table: PanelContainer = %GridOfStudents

## Access to the popup panel that allows for a new student to be added
@onready var popup_panel: PopupPanel = %PopupPanel
#endregion

#region report variables
## Access to the report types
@onready var option_report_type: OptionButton = %OptionReportType

# Access to the Report Type box
@onready var hbox_report_type: HBoxContainer = $ScrollContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainerGenerateReports/VBoxContainer/HBoxReportType

## Access to the select student box
@onready var hbox_student_report: HBoxContainer = %HBoxStudentReport

## Access to the student options
@onready var option_students: OptionButton = %OptionStudents

## Access to the sort by box
@onready var hbox_sort_by: HBoxContainer = %HBoxSortBy

## Access to the date range box
@onready var hbox_date_range: HBoxContainer = %HBoxDateRange

## Access to the subject box
@onready var hbox_subjects: HBoxContainer = %HBoxSubjects

## Access to the selected subjects container
@onready var panel_selected_subjects: PanelContainer = %PanelContainerSelectedSubjects

## Access to the generate report button
@onready var btn_generate_report: Button = %BtnGenerateReport

## Access to the text input for the from date
@onready var line_edit_date_from: LineEdit = %LineEditDateFrom

## Access to the text input for the to date
@onready var line_edit_date_to: LineEdit = %LineEditDateTo

## Access to the subject options for the report
@onready var option_subjects: OptionButton = %OptionSubjects

## Access to the associated subjects for the student
@onready var vbox_selected_subjects: VBoxContainer = %VBoxSelectedSubjects

## Access to the label to display whether the report was generated or not
@onready var label_notification: RichTextLabel = %LabelNotification

#endregion


## List of students saved on the user's drive
var student_directory : Array[Student]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Open the student directory
	student_directory = CMDatabaseUtilities.get_student_list()
	
	if student_directory.size() <= 1:
		student_table.visible = false
	else:
		student_table.visible = true
	pass


## Shows the popup panel to add a student
func _on_btn_add_student_pressed() -> void:
	popup_panel.show()
	
	# Populate the grade options
	for grade in CMDatabaseUtilities.GRADES:
		option_grade.add_item(grade.replace("_", " "))
	pass 


## Hides the add student popup panel
func _on_popup_btn_cancel_pressed() -> void:
	popup_le_name.text = ""
	option_grade.selected = 0
	popup_panel.hide()
	pass 


## Saves the student to the database
func _on_popup_btn_save_pressed() -> void:
	# Student's must have a name
	if popup_le_name.text.is_empty():
		var style = CMDatabaseUtilities.error_style_box_flat()
		popup_le_name.add_theme_stylebox_override("normal", style)
	else:
		var new_student : Student = Student.new()
		new_student.name = popup_le_name.text
		new_student.grade =  option_grade.selected
		new_student.is_active = true
		
		CMDatabaseUtilities.add_student(new_student)
		
		# Reset form
		popup_le_name.text = ""
		option_grade.selected = -1
		popup_le_name.remove_theme_stylebox_override("normal")
		popup_panel.hide()
		
		SignalBus.refresh_student_table.emit()
	pass


## Calls the function to load JSON objects in as ResourceItems
func _on_button_pressed() -> void:
	CMDatabaseUtilities.parse_json_data()
	pass 


#region Report functions
## Displays the required fields for each specific report
func _on_option_progress_type_item_selected(index: int) -> void:
	if index == 0: # Report
		hbox_student_report.visible = true
		#hbox_sort_by.visible = true
		hbox_date_range.visible = true
		hbox_subjects.visible = true
		btn_generate_report.visible = true
		
		populate_student_report_filter()
		populate_subjects_for_student(option_students.get_item_metadata(option_students.get_selected_id()))
	elif index == 1: # Attendance
		hbox_student_report.visible = false
		#hbox_sort_by.visible = false
		hbox_date_range.visible = false
		hbox_subjects.visible = false
		btn_generate_report.visible = true
	else: # Bibliography
		hbox_student_report.visible = false
		#hbox_sort_by.visible = false
		hbox_date_range.visible = false
		hbox_subjects.visible = false
		btn_generate_report.visible = true
	pass


## Populates the student option button with all available students
func populate_student_report_filter() -> void:
	var student_list = CMDatabaseUtilities.get_student_list()
	for i in student_list.size():
		option_students.add_item(student_list[i].name)
		option_students.set_item_metadata(i, student_list[i])
	pass


## Populate the SelectedSubject options based on the student
func populate_subjects_for_student(p_student : Student) -> void:
	var subject_list : Array[Subject]= CMDatabaseUtilities.get_subject_list()
	var selected_subjects : Array[ResourceData.Subjects] = []
	
	# Clear list on re-populate
	if panel_selected_subjects.get_child(0).get_child_count() > 0:
		for i in panel_selected_subjects.get_child(0).get_child_count():
			panel_selected_subjects.get_child(0).get_child(i).call_deferred("queue_free")
	
	# Get all subjects for the selected student
	for i in subject_list.size():
		if subject_list[i].student == p_student:
			if !selected_subjects.has(subject_list[i].subject):
				selected_subjects.append(subject_list[i].subject)
	
	# Populate subject list
	if selected_subjects.is_empty():
		btn_generate_report.disabled = true
	else:
		for i in selected_subjects.size():
			var checkbox : CheckBox = CheckBox.new()
			panel_selected_subjects.get_child(0).add_child(checkbox)
			checkbox.text = str(ResourceData.Subjects.keys()[selected_subjects[i]]).replace("_", " ")
			checkbox.set_meta("subject", ResourceData.Subjects.keys()[selected_subjects[i]])
		
		btn_generate_report.disabled = false
	pass


## If Selected Subjects is selected, display all subjects
func _on_option_subjects_item_selected(index: int) -> void:
	if index == 0: # All subjects
		pass
	if index == 1: # Selected SUbjects
		panel_selected_subjects.visible = true
	pass


## Populates the subject list for the selected Student
func _on_option_students_item_selected(index: int) -> void:
	populate_subjects_for_student(option_students.get_item_metadata(index))
	pass


## Generates the selected report
func _on_btn_generate_report_pressed() -> void:
	var from_date_result = CMDatabaseUtilities.verify_date_format(line_edit_date_from.text)
	var to_date_result = CMDatabaseUtilities.verify_date_format(line_edit_date_to.text)
	
	# Remove any existing error boxes
	line_edit_date_from.remove_theme_stylebox_override("normal")
	line_edit_date_to.remove_theme_stylebox_override("normal")
	
	# Mark the form for any date errors
	if from_date_result == false:
		line_edit_date_from.add_theme_stylebox_override("normal", error_box())
		if to_date_result == false:
			line_edit_date_to.add_theme_stylebox_override("normal", error_box())
		return
	elif to_date_result == false:
		line_edit_date_to.add_theme_stylebox_override("normal", error_box())
		return
	
	# Verify the from date is before the to date
	var formatted_from_date = CMDatabaseUtilities.convert_string_to_date(line_edit_date_from.text)
	var formatted_to_date = CMDatabaseUtilities.convert_string_to_date(line_edit_date_to.text)
	
	if !formatted_from_date.is_before(formatted_to_date):
		line_edit_date_from.add_theme_stylebox_override("normal", error_box())
		line_edit_date_to.add_theme_stylebox_override("normal", error_box())
		return
	
	# If there are no errors, generate the report! Woohoo!
	if option_report_type.selected == 0: # Report
		var student : Student = option_students.get_selected_metadata()
		var subjects : Array[ResourceData.Subjects] = []
		
		if option_subjects.selected == 0: # all resources
			for i in vbox_selected_subjects.get_child_count():
				var title = vbox_selected_subjects.get_child(i).get_meta("subject")
				subjects.append(ResourceData.Subjects[title])
		elif option_subjects.selected == 1: # selected resources
			for i in vbox_selected_subjects.get_child_count():
				if vbox_selected_subjects.get_child(i).is_pressed():
					subjects.append(ResourceData.Subjects[vbox_selected_subjects.get_child(i).get_meta("subject")])
		
		var result = CMDatabaseUtilities.generate_report(student, formatted_from_date.to_string(), formatted_to_date.to_string(), subjects)
		
		if result.is_empty():
			label_notification.text = "Report was unable to be generated"
		else:
			label_notification.text = "Progress report for " + student.name + " was created at " + result
		
	elif option_report_type.selected == 1: # Attendance
		pass
	elif option_report_type.selected == 2 : # Bibliography
		pass
	pass


## Creates a red stylebox 
func error_box() -> StyleBoxFlat:
	var red_border = StyleBoxFlat.new()
	red_border.border_color = Color.RED
	red_border.border_width_bottom = 2
	red_border.border_width_left = 2
	red_border.border_width_right = 2
	red_border.border_width_top = 2

	return red_border
#endregion
