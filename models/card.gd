################################################################################
### Data model for a study Card for a memorize set
################################################################################
class_name Card
extends Resource

## Begin date of the study card
@export var date_started : String

## Title of the study card
@export var title : String

## Subtitle of the study card
@export var subtitle : String

## Content for the study card
@export var content : String

## Completion status of the study card
@export var is_finished : bool = false 
