@tool
extends Control

var Plugin = Engine.get_meta("DataManager")

var command_history := []

func _ready():
	pass

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	
	pass

func refresh():
	pass
