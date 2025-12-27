## Division Item that populates the Division section on a ResourceItem
extends Control

@onready var rt_lbl_counter: RichTextLabel = %RTLblCounter
@onready var le_line_item_text: LineEdit = %LeLineItemText
@onready var btn_delete_line_item: Button = %BtnDeleteLineItem


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Removes the selected line item
func _on_btn_delete_line_item_pressed() -> void:
	SignalBus.division_item_deleted.emit(self)
	pass 


## Updates the text in the RichTextLabel for the counter
func update_label_counter(index:String) -> void:
	rt_lbl_counter.text = index
	pass


## Updates the text in the LineEdit Text
func update_text(new_text:String) -> void:
	le_line_item_text.text = new_text
	pass


## Get the division item text
func get_text() -> String:
	return le_line_item_text.text


## Disables the text line for viewing purposes
func disable_text() -> void:
	le_line_item_text.editable = false
	pass


## Enables the text line for editing purposes
func enable_text() -> void:
	le_line_item_text.editable = true
	pass


## Disables the delete button for viewing purposes
func disable_delete_button() -> void:
	btn_delete_line_item.disabled = true
	pass


## Enables the delete button for editing purposes
func enable_delete_button() -> void:
	btn_delete_line_item.disabled = false
	pass
