## Event bus for signaling between nodes 
extends Node

## Emitted when a new resource page should be displayed
@warning_ignore("unused_signal")
signal display_new_resource_page

## Emitted when the all resource page should be displayed
@warning_ignore("unused_signal")
signal display_all_resource_page

## Emitted when a LineItem is selected to display the resource page
@warning_ignore("unused_signal")
signal display_resource_info(resource)

## Emitted when the ResourceScheduler view should be displayed
@warning_ignore("unused_signal")
signal display_resource_schedule_page(resource)

## Emitted when the Schedule Page should be displayed
@warning_ignore("unused_signal")
signal display_schedule_page

## Emitted when the division line item's delete button is pressed
@warning_ignore("unused_signal")
signal division_item_deleted(division_item)

## Emitted when the student table needs to be updated
@warning_ignore("unused_signal")
signal refresh_student_table

## Emitted when a date is selected for a resource schedule
@warning_ignore("unused_signal")
signal date_selected(date)
