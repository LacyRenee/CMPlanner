extends Control

## Path to the card scene
const CARD_SCENE_PATH = preload("uid://cwtvuhdc01pbi")

## Container for the list of cards
@onready var scroll_container_placeholder: ScrollContainer = %ScrollContainerPlaceholder

## The parent to attach the cards to
@onready var v_box_placeholder: VBoxContainer = %VBoxPlaceholder

## Access to the title of the memory set
@onready var le_title: LineEdit = $VBoxContainer/HBoxTitle/LeTitle

## Access to the subtitle of the memory set
@onready var le_subtitle: LineEdit = %LeSubtitle

## Access to the start date of the memory set
@onready var le_start_date: LineEdit = %LeStartDate

## Access to the description of the memory set
@onready var le_description: LineEdit = %LeDescription

## Access to the popup panel
@onready var popup_panel: PopupPanel = %PopupPanel

## Access to the popup title
@onready var lbl_title: RichTextLabel = %LblTitle

## Access to the popup content
@onready var lbl_content: RichTextLabel = %LblContent

## Access to the popup OK button
@onready var btn_ok: Button = %BtnOK

## Access to the popup cancel button
@onready var btn_cancel: Button = %BtnCancel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("delete_card", delete_card)
	pass


func delete_card(p_card) -> void:
	v_box_placeholder.remove_child(p_card)
	p_card.queue_free()
	pass


func create_set() -> Set:
	# Create the set
	var new_set : Set = Set.new()
	new_set.title = le_title.text
	new_set.subtitle = "" if le_subtitle.text.is_empty() else le_subtitle.text
	new_set.start_date = "" if le_start_date.text.is_empty() else le_start_date.text 
	new_set.description = "" if le_description.text.is_empty() else le_description.text
	
	# Add all of the cards to the set list
	for i in v_box_placeholder.get_child_count():
		var new_card : Card = Card.new()
		new_card.title = v_box_placeholder.get_child(i).le_title.text
		new_card.content = v_box_placeholder.get_child(i).le_content.text
		
		new_set.card_list.append(new_card)
	
	return new_set


## Add a new card to the Memorize Set
func _on_btn_add_card_pressed() -> void:
	scroll_container_placeholder.visible = true
	
	var instance = CARD_SCENE_PATH.instantiate()
	v_box_placeholder.add_child(instance)
	pass


## Begin the process to save the new Memorize Set
func _on_btn_save_card_pressed() -> void:
	# Error check the Memorize Set
	if le_title.text.is_empty():
		le_title.add_theme_stylebox_override("normal",CMDatabaseUtilities.error_style_box_flat())
		return
	
	# Error check the cards
	var count_errors : int = 0
	for card in v_box_placeholder.get_child_count():
		if v_box_placeholder.get_child(card).le_title.text.is_empty():
			v_box_placeholder.get_child(card).le_title.add_theme_stylebox_override("normal", CMDatabaseUtilities.error_style_box_flat())
			count_errors += 1
		else:
			v_box_placeholder.get_child(card).le_title.remove_theme_stylebox_override("normal")
			
		if v_box_placeholder.get_child(card).le_content.text.is_empty():
			v_box_placeholder.get_child(card).le_content.add_theme_stylebox_override("normal", CMDatabaseUtilities.error_style_box_flat())
			count_errors += 1
		else:
			v_box_placeholder.get_child(card).le_content.remove_theme_stylebox_override("normal")
			
	if count_errors > 0:
		return
	
	# Verify no duplicates
	var new_set : Set = create_set()
	var result = CMDatabaseUtilities.check_title_duplication(new_set)
	if result == "OK":
		popup_panel.show()
		lbl_title.text = "Success!"
		lbl_content.text = new_set.title + " was created successfully!"
		btn_cancel.visible = false
	elif result == "duplicate":
		popup_panel.show()
		lbl_title.text = "Duplicate Found"
		lbl_content.text = "Unable to save the current set. Please rename"
		btn_ok.visible = false
		btn_cancel.text = "OK"
	else:
		popup_panel.show()
		lbl_title.text = "Warning!"
		lbl_content.text = "A similar title was found: " + result + ". Are you sure you want to save?"
		btn_ok.visible = true
		btn_cancel.visible = true
		btn_cancel.text = "Cancel"
	pass


func _on_popup_btn_ok_pressed() -> void:
	CMDatabaseUtilities.save_set(create_set())
	SignalBus.display_memorize_page.emit()
	pass


func _on_popup_btn_cancel_pressed() -> void:
	popup_panel.hide()
	pass 
