################################################################################
## PanelContainerSubject
## The allocated node to hold all students for the specified subject
################################################################################
extends PanelContainer

## Access to the subject cbox
@onready var v_box_subject: VBoxContainer = %VBoxSubject

## Access to the subject label
@onready var lbl_subject: RichTextLabel = %LblSubject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 


## Sets the title of the Subject
func set_subject(p_subject : String) -> void:
	lbl_subject.text = p_subject
	pass


## Get the subject
func get_subject() -> String:
	return lbl_subject.text
