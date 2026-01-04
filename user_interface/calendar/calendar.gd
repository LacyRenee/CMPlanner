################################################################################
### Calendar View for a month at a time
### Able to go to previous months and next months
### Made with the calendar_library plugin
################################################################################
extends Control

@onready var panel_container: PanelContainer = %PanelContainer

## Access to the calendar header label
@onready var lbl_calendar_header: Label = %LblCalendarHeader

## Access to the grid calendar header labels
@onready var grid_calendar_week_header: GridContainer = %GridCalendarWeekHeader

## Access to the grid container for the calendar
@onready var grid_calendar_dates: GridContainer = %GridCalendarDates

## utility for all things calendar related
var calendar : Calendar = Calendar.new()

## Selected month
var month : int

## Selected year
var year : int

## Selected date from the calendar
var selected_date : Calendar.Date 

## A reference to today's current date
var todays_date : Calendar.Date

# Placeholder label for when a date is selected
var selected_date_label : Label 


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the current date
	todays_date = Calendar.Date.today()
	selected_date = todays_date
	year = todays_date.year
	month = todays_date.month
	
	calendar.set_first_weekday(Time.WEEKDAY_SUNDAY)
	
	## Sets header label with the selected Month and Year 
	set_calendar_header()
	
	populate_calendar_month()
	
	pass 


## Adds all of the days in the month to the calendar
func populate_calendar_month() -> void:
	var month_calendar = calendar.get_calendar_month(year, month, true)
	
	for week in month_calendar:
		for date in week:
			# Create the Panel Container
			var date_container : PanelContainer = add_date_panel_container()
			
			# Create the margin container
			var date_margin_container : MarginContainer = add_date_margin_container()
			
			# Create the date label
			var date_label : CalendarLabel = CalendarLabel.new(str(date.day), true)
			date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			date_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			date_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			date_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			date_label.pressed.connect(_on_date_pressed.bind(date, date_label))
			
			if date.month == month:
				if date.is_equal(todays_date):
					date_label.label_settings.font_color = Color.BLUE
					set_selected_state(date_label)
				else:
					date_label.label_settings.font_color = Color.BLACK
			else:
				date_label.label_settings.font_color = Color.GRAY
			
			
			
			
			# Attach to the scene tree
			date_margin_container.add_child(date_label)
			date_container.add_child(date_margin_container)
			grid_calendar_dates.add_child(date_container)
	pass


## Creates the panel container for the date calendar
func add_date_panel_container()-> PanelContainer:
	var window_size = get_viewport().get_visible_rect().size
	
	var panel : PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(window_size.x / 7, window_size.y / 7)
	
	
	return panel


## Creates the margin container for the date calendar
func add_date_margin_container() -> MarginContainer:
	var container : MarginContainer = MarginContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	return container


## Highlights the selected date
func set_selected_state(date_label : Label) -> void:
	if selected_date_label and selected_date_label.get_child_count() > 0:
		selected_date_label.get_child(0).queue_free()
		
	var selected_rect: ColorRect = ColorRect.new()
	selected_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	selected_rect.color = Color.SLATE_GRAY
	selected_rect.show_behind_parent = true
	date_label.add_child(selected_rect)
	
	selected_date_label = date_label
	pass


## Sets the month and year
func set_calendar_header() -> void:
	var formatted_month = calendar.get_month_formatted(month, calendar.MonthFormat.MONTH_FORMAT_FULL)
	lbl_calendar_header.text = formatted_month + " " + str(year)
	pass


## Removes all of the dates from the calendar view
func clear_calendar() -> void:
	selected_date_label = null
	
	for child in grid_calendar_dates.get_children():
		child.queue_free()	
	pass


### ############################################################################
### Signal Methods
################################################################################

## Changes the calendar view to the previous month
func _on_btn_previous_month_pressed() -> void:
	# Validate the month and set the year if needed
	if month == 1:
		month = 12 
		year -= 1
	else:
		month -= 1
	
	clear_calendar()
	set_calendar_header()
	populate_calendar_month()
	pass 


## Changes the calendar view to the next month
func _on_btn_next_month_pressed() -> void:
	# Validate the month and set the year if needed
	
	if month == 12:
		month = 1
		year += 1
	else:
		month += 1
	
	clear_calendar()
	set_calendar_header()
	populate_calendar_month()
	pass


# Selectes the date pressed from the calendar
func _on_date_pressed(date: Calendar.Date, date_label: Label):
	set_selected_state(date_label)
	#set_date_label(date)
	selected_date = date
	pass


################################################################################
### Helper class for generating date labels.
################################################################################
class CalendarLabel:
	extends Label
	
	var clickable: bool = false
	
	signal pressed()
	
	
	func _init(p_text: String, p_clickable: bool = false):
		text = p_text
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_settings = LabelSettings.new()
		
		if p_clickable:
			clickable = p_clickable
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			mouse_filter = Control.MOUSE_FILTER_STOP
	
	
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			if clickable:
				pressed.emit()
	
