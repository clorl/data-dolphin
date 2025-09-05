@tool
extends Control

var Plugin = Engine.get_meta("DataPlugin")

var command_history := []

func _ready():
	pass

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	
	# if event is InputEventKey and event.is_pressed():
	# 	var shortcut: String = plugin.get_editor_shortcut(event)
	# 	match shortcut:
	#
	#get_viewport().set_input_as_handled()
	pass

func refresh():
	pass
