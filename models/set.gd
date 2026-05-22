class_name Set
extends Resource

## Title of the set
@export var title : String

## The date to begin studying
@export var start_date : String

## Date the set is completed
@export var end_date : String

## A description of the Set to memorize
@export var description : String

## A list of all cards for the set
@export var card_list : Array[Card] = []

## Specifies whether the user is done studying the set
@export var is_finished : bool
