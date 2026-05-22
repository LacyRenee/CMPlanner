extends FoldableContainer

@onready var le_description: TextEdit = %LeDescription

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Must use call deferred bc the node isn't in the tree yet
	call_deferred("resize_description")
	
	
	pass


## Resizes the descritption text
func resize_description() -> void:
	le_description.custom_minimum_size.y = le_description.size.y * .25
	pass
