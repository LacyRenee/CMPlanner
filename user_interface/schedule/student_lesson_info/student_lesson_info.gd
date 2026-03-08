################################################################################
## Student Lesson Info
## Displays a general overview of the lesson for a designated subject
## Highlights the days of the week the lesson is done
## Allows the user to edit, remove, and view all assignments
################################################################################
extends VBoxContainer

## Access to the title of the assigned subject
@onready var lbl_subject_title: RichTextLabel = %LblSubjectTitle

## Access to day 1 label
@onready var lbl_day_1: RichTextLabel = %LblDay1

## Access to day 2 label
@onready var lbl_day_2: RichTextLabel = %LblDay2

## Access to day 3 label
@onready var lbl_day_3: RichTextLabel = %LblDay3

## Access to day 4 label
@onready var lbl_day_4: RichTextLabel = %LblDay4

## Access to day 5 label
@onready var lbl_day_5: RichTextLabel = %LblDay5

## Access to day 6 label
@onready var lbl_day_6: RichTextLabel = %LblDay6

## Access to day 7 label
@onready var lbl_day_7: RichTextLabel = %LblDay7

## Access to the division type
@onready var lbl_division_type: RichTextLabel = %LblDivisionType

## Access to the lesson method
@onready var lbl_lesson_method: RichTextLabel = %LblLessonMethod

## Access to the assignment start value
@onready var lbl_start: RichTextLabel = %LblStart

var subject : Subject 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 


## Sets the scene's subject
func set_subject(p_subject : Subject) -> void:
	subject = p_subject
	pass

func get_subject() -> Subject:
	return subject


## Removes the subject from the schedule
func _on_btn_remove_from_schedule_pressed() -> void:
	CMDatabaseUtilities.remove_subject_from_schedule(subject)
	SignalBus.refresh_scheduled_subject_view.emit()
	pass 


## Changes the scene to the ResourceScheduler view
## allowing the assignmnet to be edited
func _on_btn_edit_schedule_pressed() -> void:
	SignalBus.display_edited_resource_schedule_page.emit(subject)
	pass 


## Changes the scene to the resource_assignment view
func _on_btn_view_schedule_pressed() -> void:
	SignalBus.display_resource_assignments_page.emit(subject)
	pass
