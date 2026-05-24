extends FoldableContainer

## Access to the card title
@onready var le_title: LineEdit = %LeTItle

## Access to the card description
@onready var le_content: TextEdit = %LeContent

## Access to the card date
@onready var le_start_date: LineEdit = %LeStartDate


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Must use call deferred bc the node isn't in the tree yet
	call_deferred("resize_description")
	
	
	pass


## Resizes the descritption text
func resize_description() -> void:
	le_content.custom_minimum_size.y = le_content.size.y * .25
	pass


## Removes the card from the Memorize set
func _on_btn_delete_card_pressed() -> void:
	SignalBus.delete_card.emit(self)
	pass 
