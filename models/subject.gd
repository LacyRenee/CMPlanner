################################################################################
### Contains all information required to schedule a subject
################################################################################
class_name Subject
extends Resource

@export var subject : ResourceData.Subjects

## Selected resource for the subject
@export var resource : ResourceItem

## Student to which the subject is assigned
@export var student : Array[Student] = []

## Method in which the subject is to be studied
@export var study_method : ResourceData.study_method

# Selected day or days on which the subject is to be studied
@export var week_day : Array[ResourceData.week_day]

## Day of the week the subject is to be started
@export var start_date : String

## Use after a specified resource
@export var start_after : ResourceItem

## Use in conjunction with the selected resource
@export var use_with : ResourceItem

## Specifies whether the Subject is scheduled or not
@export var is_active : bool = true

var assignments : Dictionary = {}
