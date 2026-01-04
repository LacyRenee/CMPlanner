class_name StudentList
extends Resource

@export var students : Array[Student] = []

func add_student(p_student) -> void:
	students.append(p_student)
