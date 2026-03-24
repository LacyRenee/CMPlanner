################################################################################
### Provides a detailed view of the assignment so that progress can be tracked
################################################################################
extends FoldableContainer

## Access to the assignment's progress options
@onready var option_button_progress: OptionButton = %OptionButtonProgress

## Access to the assignment's division title label
@onready var lbl_division_title: RichTextLabel = %LblDivisionTitle

## Access to the assignment's study method label
@onready var lbl_study_method: RichTextLabel = %LblStudyMethod

## Access to the assignment notes
@onready var text_edit_notes: TextEdit = %TextEditNotes

## Access to the assignment's date
@onready var lbl_date: RichTextLabel = %LblDate

## Access to the timer to close the save note confirmation popup
@onready var timer_save_note: Timer = %TimerSaveNote

## Access to the confirmation popup when a note is saved
@onready var popup_panel_save_note: PopupPanel = %PopupPanelSaveNote

## Access to the save note button
@onready var btn_save_notes: Button = %BtnSaveNotes


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for option in ResourceData.progress:
		option_button_progress.add_item(option.replace("_", " "))
	pass 


## Save the progress state
func _on_option_button_progress_item_selected(index: int) -> void:
	# Save progress state
	CmDatabaseUtilities.save_assignment_progress(self.get_meta("subject"), self.get_meta("assignment"), index)
	
	# Display completion status in the title of the assignment
	if index == ResourceData.progress.Completed or\
	   index == ResourceData.progress.Omit_assignment or\
	   index == ResourceData.progress.Complete_and_finish:
		var formatted_date = CMDatabaseUtilities.get_formatted_date(CMDatabaseUtilities._calendar.Date.today())
		self.title = self.get_meta("subject").resource.title + " - " + \
			 ResourceData.progress.keys()[index].replace("_", " ") + " on " + formatted_date
		self.fold()
	else:
		self.title = self.get_meta("subject").resource.title
		
	# Display the next assignment 
	SignalBus.display_next_assignment.emit() 
	pass


## Save the assignment note
func _on_btn_save_notes_pressed() -> void:
	if !text_edit_notes.text.is_empty():
		CMDatabaseUtilities.save_assignment_note(self.get_meta("subject"), self.get_meta("assignment"), text_edit_notes.text)
		var x = int(btn_save_notes.global_position.x) - 5
		var y = int (btn_save_notes.global_position.y) + 40

		popup_panel_save_note.position = Vector2i(x, y)
		popup_panel_save_note.show()
		
		timer_save_note.start()
		timer_save_note.connect("timeout", _on_timer_save_note_timeout)
	pass 


## Hides the popup window for the save note 
func _on_timer_save_note_timeout():
	popup_panel_save_note.hide()
	pass
