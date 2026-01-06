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

var start_after

var use_with
