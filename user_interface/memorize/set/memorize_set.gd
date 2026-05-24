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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("delete_card", delete_card)
	pass


func delete_card(p_card) -> void:
	v_box_placeholder.remove_child(p_card)
	p_card.queue_free()
	pass


func create_set() -> void:
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
	pass


## Add a new card to the Memorize Set
func _on_btn_add_card_pressed() -> void:
	scroll_container_placeholder.visible = true
	
	var instance = CARD_SCENE_PATH.instantiate()
	v_box_placeholder.add_child(instance)
	pass


## Begin the process to save the new Memorize Set
func _on_btn_save_card_pressed() -> void:
	if le_title.text.is_empty():
		le_title.add_theme_stylebox_override("normal",CMDatabaseUtilities.error_style_box_flat())
		return
	else:
		create_set()
	pass
