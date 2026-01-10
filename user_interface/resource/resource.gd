################################################################################
### Form to create/view/edit a new ResourceItem 
################################################################################
extends Control

# Path to the division item scene
const DIVSION_SCENE_PATH : String = "res://user_interface/division_item/division_item.tscn"


## onready variables
#region
## Access to the title line edit text
@onready var title: LineEdit = %LeTitle

## Access to the isbn line edit text
@onready var isbn: LineEdit = %LeISBN

## Access to the contributor options
@onready var contributor_options: OptionButton = %ObContributor

## Access to the contributor name line edit text
@onready var contributor_name: LineEdit = %LeContributorName

## Access to the resource type options
@onready var resource_type_options: OptionButton = %ObResourceType

## Access to the subject options
@onready var ob_subject: OptionButton = %ObSubject

## Access to the division type options
@onready var division_type_options: OptionButton = %ObDivisionType

## Access to the url line edit
@onready var le_url: LineEdit = %LEUrl

## Access to the publisher line edit text
@onready var le_publisher: LineEdit = %LePublisher

## Access to the copyright date line edit text
@onready var le_copyright_date: LineEdit = %LECopyrightDate

## Access to the year written line edit text
@onready var le_year_written: LineEdit = %LeYearWritten

## Access to the number of pages line edit text
@onready var le_number_of_pages: LineEdit = %LeNumberOfPages

## Access to the edition line edit text
@onready var le_edition: LineEdit = %LeEdition

## Access to the description line edit text
@onready var le_description: LineEdit = %LeDescription

## The allocated space on the form for the division line items to be displayed if division type is NOT 'None'
@onready var division_container: VBoxContainer = %VBoxCDivisionList

## The vbox that specifically holds all of the division items
@onready var division_list: VBoxContainer = %VBoxCDivision

## Access to the "Add More Division Items" button
@onready var division_button: Button = %BtnDivision

## Access to the save button
@onready var btn_save: Button = %BtnSave

## Access to the edit button
@onready var btn_edit: Button = %BtnEdit

## Access to the update button
@onready var btn_update: Button = %BtnUpdate

## Access to the schedule it button
@onready var btn_schedule: Button = %BtnSchedule

## Access to the delete button
@onready var btn_delete: Button = %BtnDelete


#endregion


## The Resource that is to be saved to the database
var resource_item = ResourceItem.new()

## File path to the selected resource item
var resource_item_path : String = ""

## Preload the division line item in case it's needed
var division_line_item = preload(DIVSION_SCENE_PATH)

## Shows which view the user is in: new, edit, view
var view_option : ResourceData.ViewingOptions


## Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	# Set the view_option
	update_view_option(ResourceData.ViewingOptions.New)
	
	# Populate all the dropdowns on the form
	#region
	# Populate the Contributor List
	for c in ResourceData.Contributors :
		contributor_options.add_item(c)
	
	# Populate the Resource Type options	
	for r in ResourceData.ResourceType :
		resource_type_options.add_item(r)
	
	# Populate the Division Type options
	for d in ResourceData.DivisionType :
		division_type_options.add_item(d)
	
	# Populate the Subject options
	for s in ResourceData.Subjects :
		ob_subject.add_item(s)
	#endregion
	
	# Listens for a division item to be deleted
	SignalBus.connect("division_item_deleted", delete_division_item)
	
	pass 


## Updates the view option
func update_view_option(p_option : ResourceData.ViewingOptions) -> void:
	view_option = p_option
	update_view()
	pass


## Update the View based on the view option
func update_view() -> void:
	# Toggle which finalization button is on the form
	match view_option:
		ResourceData.ViewingOptions.New:
			# Toggle correct buttons
			btn_save.visible = true
			btn_edit.visible = false
			btn_update.visible = false
			btn_schedule.visible = false
			btn_delete.visible = false
			
			enable_form_fields()
			
		ResourceData.ViewingOptions.Edit:
			btn_save.visible = false
			btn_edit.visible = false
			btn_update.visible = true
			btn_schedule.visible = false
			btn_delete.visible = true
			
			enable_form_fields()
			
			var division_items = division_list.get_children()
			
			if division_items.is_empty():
				pass
			else:
				for item in division_items:
					item.enable_text()
					item.enable_delete_button()
			
		ResourceData.ViewingOptions.View:
			btn_save.visible = false
			btn_edit.visible = true
			btn_update.visible = false
			btn_schedule.visible = true
			btn_delete.visible = false
			btn_delete.visible = true
			
			title.editable = false
			isbn.editable = false
			resource_type_options.disabled = true
			contributor_options.disabled = true
			contributor_name.editable = false
			ob_subject.disabled = true
			le_url.editable = false
			le_publisher.editable = false
			le_copyright_date.editable = false
			le_year_written.editable = false
			le_number_of_pages.editable = false
			le_edition.editable = false
			le_description.editable = false
			division_type_options.disabled = true
			division_button.disabled = true
			
			var division_items = division_list.get_children()
			
			if division_items.is_empty():
				pass
			else:
				for item in division_items:
					item.disable_text()
					item.disable_delete_button()
		_:
			print("I don't know!")
	pass


## Enables the text fields and dropdown fields on the form
func enable_form_fields() -> void:
	title.editable = true
	isbn.editable = true
	resource_type_options.disabled = false
	contributor_options.disabled = false
	contributor_name.editable = true
	ob_subject.disabled = false
	le_url.editable = true
	le_publisher.editable = true
	le_copyright_date.editable = true
	le_year_written.editable = true
	le_number_of_pages.editable = true
	le_edition.editable = true
	le_description.editable = true
	division_type_options.disabled = false
	division_button.disabled = false
	pass


## Saves the information to the selected resource
func save_data() -> void:
	resource_item.title = title.text
	resource_item.isbn = isbn.text
	resource_item.resource_type = resource_type_options.selected as ResourceData.ResourceType
	resource_item.contributor = contributor_options.selected as ResourceData.Contributors
	resource_item.contributor_name = contributor_name.text
	resource_item.subject = ob_subject.selected as ResourceData.Subjects
	resource_item.web_url = le_url.text
	resource_item.publisher = le_publisher.text
	resource_item.copyright_date = le_copyright_date.text
	resource_item.year_written = le_year_written.text
	resource_item.number_of_pages = int(le_number_of_pages.text)
	resource_item.edition = le_edition.text
	resource_item.description = le_description.text
	
	
	# function to retrieve all division types
	if division_type_options.selected != ResourceData.DivisionType.None: 
		resource_item.division_type = division_type_options.selected as ResourceData.DivisionType
		resource_item.division_list = get_all_division_items()
	pass


## Returns an array of all of the division line items
func get_all_division_items() -> Array:
	var division_item_list = division_list.get_children()
	var array : Array[String]
	
	for i in division_item_list:
		array.append(i.get_text())
	
	return array


## Removes a Division Line Item from the Resource Form
func delete_division_item(division_item) -> void:
	division_list.remove_child(division_item)
	division_item.queue_free()
	
	renumber_divisions()
	pass


## Renumbers the division line items upon addition or deletion
func renumber_divisions() -> void:
	var all_division_items = division_list.get_children()

	if all_division_items.is_empty():
		division_container.visible = false
		division_type_options.selected = ResourceData.DivisionType.None
	else:
		# Used to number the line items
		var count = 1 
		
		for item in all_division_items:
			item.update_label_counter(str(count))
			count += 1
	pass


## Display selected Resource Information
func display_selected_resource(resource: ResourceItem) -> void:
	# Update the view!
	update_view_option(ResourceData.ViewingOptions.View)
	
	# Save the current resource
	resource_item = resource
	
	title.text = resource_item.title
	isbn.text = resource_item.isbn
	resource_type_options.selected = resource_item.resource_type
	contributor_options.selected = resource_item.contributor
	contributor_name.text = resource_item.contributor_name
	division_type_options.selected = resource_item.division_type
	
	if resource_item.division_type != ResourceData.DivisionType.None:
		division_container.show()
		division_list.remove_child(division_list.get_child(0))
		
		for item in resource_item.division_list:
			var instance = division_line_item.instantiate()
			division_list.add_child(instance)
			instance.update_text(item)
			
			instance.disable_text()
			instance.disable_delete_button()
		
		renumber_divisions()
	pass


## Red lines the title field if empty
func error_format_title_empty() -> void:
	var red_border = StyleBoxFlat.new()
	red_border.border_color = Color.RED
	red_border.border_width_bottom = 2
	red_border.border_width_left = 2
	red_border.border_width_right = 2
	red_border.border_width_top = 2
	
	title.add_theme_stylebox_override("normal", red_border)
	pass


## Shows the user that the Number of Pages field must be a number
func error_format_number_of_pages() -> void:
	var red_border = StyleBoxFlat.new()
	red_border.border_color = Color.RED
	red_border.border_width_bottom = 2
	red_border.border_width_left = 2
	red_border.border_width_right = 2
	red_border.border_width_top = 2
	
	le_number_of_pages.add_theme_stylebox_override("normal", red_border)
	pass


## Removes any format themes that were applied during errors
func remove_format_themes() -> void:
	title.remove_theme_stylebox_override("normal")
	le_number_of_pages.remove_theme_stylebox_override("normal")
	pass


# Signal Functions
#region
## Adds more division line items to the list
func _on_btn_division_pressed() -> void:
	var instance = division_line_item.instantiate()
	division_list.add_child(instance)
	renumber_divisions()
	pass 


## Allow the form to be editable
func _on_btn_edit_pressed() -> void:
	update_view_option(ResourceData.ViewingOptions.Edit)
	pass

## Saves the newly inputted ResourceItem
func _on_btn_save_pressed() -> void:
	
	## Do not save resource without a title
	if title.text.is_empty():
		error_format_title_empty()
		return
	
	if !le_number_of_pages.text.is_empty():
		if !le_number_of_pages.text.is_valid_int():
			error_format_number_of_pages()
			return
	
	# Save the form data to the resource
	save_data()
	CMDatabaseUtilities.save_resource_item(resource_item)
	
	# Remove error fromats if any
	remove_format_themes()
	
	view_option = ResourceData.ViewingOptions.View
	update_view()
	pass


## Update the selected resource with the new information
func _on_btn_update_pressed() -> void:
	# Do not save resource without a title
	if title.text.is_empty():
		error_format_title_empty()
		return
	
	if !le_number_of_pages.text.is_empty():
		if !le_number_of_pages.text.is_valid_int():
			error_format_number_of_pages()
			return
	
	# Save the data
	save_data()
	CMDatabaseUtilities.update_resource_item(resource_item)
	
	# Remove any format themes
	remove_format_themes()
	
	# Change the view
	view_option = ResourceData.ViewingOptions.View
	update_view()
	pass


## Displays the division form if the division type is NOT 'None'
func _on_ob_divistion_type_item_selected(index: int) -> void:
	
	if index > 0 :
		division_container.show()
	else:
		division_container.hide()
	pass 
#endregion


## Deletes the selected resource from the database
func _on_btn_delete_pressed() -> void:
	# Create confirmation delete dialog
	var confirm_delete_dialog = ConfirmationDialog.new()
	confirm_delete_dialog.title = "Please confirm"
	confirm_delete_dialog.dialog_text = "Are you sure you want to delete " + resource_item.title + "?"
	confirm_delete_dialog.cancel_button_text = "Cancel"
	confirm_delete_dialog.ok_button_text = "Ok"
	
	# connect signals
	confirm_delete_dialog.canceled.connect (confirm_delete_dialog_canceled)
	confirm_delete_dialog.confirmed.connect (confirm_delete_dialog_ok)
		
	# show dialog
	add_child(confirm_delete_dialog)	
	confirm_delete_dialog.keep_title_visible = true
	confirm_delete_dialog.popup_centered() # center on screen
	confirm_delete_dialog.show()


## Cancelled button for the confirm delete dialog
func confirm_delete_dialog_canceled() -> void:
	print("Nothing happens - yay!")


## Ok button for the confirm delete dialog
func confirm_delete_dialog_ok()-> void: 
	CMDatabaseUtilities.remove_resource_item(resource_item)
	SignalBus.display_all_resource_page.emit()


## Changes the view to the ResourceSceduler view
func _on_btn_schedule_pressed() -> void:
	SignalBus.display_resource_schedule_page.emit(resource_item)
	pass 
