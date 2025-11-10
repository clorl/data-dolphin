@tool
extends Control

@export var edited_resource: Resource
@export var field_editors: Array[PackedScene]
@export var field_min_size: Vector2

#@onready var ResEditor = load("../res_editor/resource_editor.tscn")
@onready var res_editor = $ResourceEditor

var _edited_res

func _ready():
	res_editor.changed.connect(_prop_changed)
	rebuild()

func _prop_changed(propname, value):
	_edited_res.set(propname, value)
	res_editor.refresh()

func rebuild():
	pass

func refresh():
	if _edited_res:
		res_editor.resource = _edited_res
		res_editor.visible = true
	else:
		res_editor.visible = false

func open(object):
	_edited_res = object
	refresh()
	return true
