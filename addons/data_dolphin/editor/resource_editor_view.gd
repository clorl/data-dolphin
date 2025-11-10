@tool
extends Control

@export var edited_resource: Resource
@export var field_editors: Array[PackedScene]
@export var field_min_size: Vector2

#@onready var ResEditor = load("../res_editor/resource_editor.tscn")
@onready var res_editor := %ResourceEditor
@onready var open_res_control := %OpenedResources

var _edited = []

var _edited_res: int = -1

func _ready():
	res_editor.changed.connect(_prop_changed)
	open_res_control.item_selected.connect(func(idx):
		print(idx)
		_edited_res = idx
		refresh()
	)
	rebuild()
	refresh()

func _prop_changed(propname, value):
	#if not visible: return
	print(_edited_res)
	_edited[_edited_res].set(propname, value)

func rebuild():
	pass

func refresh():
	if _edited_res >= 0:
		res_editor.resource = _edited[_edited_res]
		res_editor.visible = true
	else:
		res_editor.visible = false
	res_editor.refresh()

	open_res_control.clear()
	for r in _edited:
		open_res_control.add_item(r.resource_path)

	if _edited_res >= 0:
		open_res_control.select(_edited_res)

func open(object):
	var found = _edited.rfind(object)
	if found > -1:
		_edited_res = found
		refresh()
		return true
	_edited.append(object)
	_edited_res = _edited.size() - 1
	refresh()
	return true
