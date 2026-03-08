################################################################################
### Resource Assignments
### Displays all the assignments associated with a resource
### To allow for easier editing. 
################################################################################
extends PanelContainer

const ASSIGNMENT_ROW : String = "res://user_interface/schedule/resource_assignments/hbox_assignment_row.tscn"

## Access to the title of the ResourceItem
@onready var label_resource_title: RichTextLabel = %LabelResourceTitle

## Access to the table of assignments
@onready var v_box_assignment_table: VBoxContainer = %VBoxAssignmentTable


# Holds the original assignment date
var old_date : String = ""

# Holds the original assignment progress option
var old_progress : ResourceData.progress

# Holds the original assignment notes
var old_notes : String = ""

## The currently viewed subject
var subject : Subject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Displays all of the assignments associated with the resource
	SignalBus.connect("display_resource_assignments", display_assignments, 0)
	
	## Commits the updates to the database
	SignalBus.connect("update_resource_assignments", update_assignments, 0)
	pass


## Displays all the rows of assignments for the selected resource
func display_assignments(p_subject : Subject) -> void:
	# Assign the subject
	subject = p_subject 
	
	# Assign the ResourceItem title
	label_resource_title.text = p_subject.resource.title
	
	var count : int = 1
	for assignment in p_subject.assignments:
		var assignment_row = load(ASSIGNMENT_ROW)
		var instance = assignment_row.instantiate()
		v_box_assignment_table.add_child(instance)
		
		instance.set_label_count(str(count) + ". ")
		instance.set_label_title(assignment.title)
		instance.set_label_date(assignment.completed_date)
		instance.set_option_progress(assignment.progress)
		instance.set_notes(assignment.notes)
		
		# Save the old data
		old_date = assignment.completed_date
		old_progress = assignment.progress
		old_notes = assignment.notes
		
		count += 1
	pass


## Updates the new information for the assignment
func update_assignments(index : int, p_date : String, p_progress : ResourceData.progress, p_notes : String) -> void:
	# Verify that the new data is not the same as the old
	if old_date == p_date and \
		old_progress == p_progress and \
		old_notes == p_notes:
			return
	else:
		if p_progress == ResourceData.progress.Completed or \
		   p_progress == ResourceData.progress.Omit_assignment:
			if p_date == "NA":
				p_date = Calendar.Date.today().to_string()
				v_box_assignment_table.get_child(index + 1).get_child(2).text = p_date
			
		subject.assignments[index].completed_date = p_date
		subject.assignments[index].progress = p_progress
		subject.assignments[index].notes = p_notes
		
		CMDatabaseUtilities.update_subject(subject)
	pass
