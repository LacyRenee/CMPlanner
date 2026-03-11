################################################################################
### Contains all information required to schedule a subject
################################################################################
class_name Subject
extends Resource

@export var subject : ResourceData.Subjects

## Selected resource for the subject
@export var resource : ResourceItem

## Student to which the subject is assigned
@export var student : Student

## Method in which the subject is to be studied
@export var study_method : ResourceData.study_method

## Selected day or days on which the subject is to be studied
@export var week_days : Array[ResourceData.week_day]

## Day of the week the subject is to be started
@export var start_date : String

## Use after a specified resource
@export var start_after : Subject

## Selected division type used for assignments
@export var division_type : ResourceData.DivisionType

## Assignments to be scheduled for the student
@export var assignments : Array[Assignment] = []  

## Daily notes
@export var daily_notes : Array[DailyNotes] = []

## True when all assignments have been completed/omitted
@export var is_finished : bool = false


## Built-in class to hold the daily notes
class DailyNotes:
	extends Resource
	
	## Date the note was made
	var date : String = ""
	
	## Note information for the daily assignment
	var note : String = ""
