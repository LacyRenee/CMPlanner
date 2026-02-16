################################################################################
## PanelContainerStudent
## The allocated node to hold all assignments for the specified subject
################################################################################
extends PanelContainer

## Access to the label for the student name
@onready var lbl_student: RichTextLabel = %LblStudent

## Access to the student vbox
@onready var vbox_student: VBoxContainer = %VBoxStudent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func set_student_name(p_name : String) -> void:
	lbl_student.text = p_name
	pass


func get_student_name() -> String:
	return lbl_student.text
