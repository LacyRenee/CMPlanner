extends Control

## Path to the memorize set
const MEMORIZE_SET_SCENE_PATH = preload("uid://d4m604xss1vsu")

## Holds a new memorize set
@onready var panel_container_holder: PanelContainer = %PanelContainerHolder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


## Displays the memorize set
func _on_btn_new_set_pressed() -> void:
	if panel_container_holder.get_child_count() == 0:
		var instance = MEMORIZE_SET_SCENE_PATH.instantiate()
		panel_container_holder.add_child(instance)
	pass
