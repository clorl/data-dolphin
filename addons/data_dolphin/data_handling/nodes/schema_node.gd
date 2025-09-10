@icon("res://addons/data-dolphin/data_handling/nodes/node.svg")
@tool
class_name SchemaNode extends Node

func get_code() -> String:
	return "@export var %s = null" % name.to_snake_case()
