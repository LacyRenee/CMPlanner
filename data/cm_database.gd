class_name CMDatabase
extends Node

## User resources folder
const 	RESOURCES = "/resources"

var cm_database : String = ""

func _ready() -> void:
	cm_database = OS.get_user_data_dir()
	pass

func get_db_resource_filepath() -> String:
	return cm_database + RESOURCES
