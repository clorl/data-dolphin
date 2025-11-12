@tool
extends Control

@export var edited_resource: Resource
@export var field_editors: Array[PackedScene]
@export var field_min_size: Vector2

#@onready var ResEditor = load("../res_editor/resource_editor.tscn")
@onready var res_editor := %ResourceEditor
@onready var tabs := %OpenedResources
@onready var ctx_menu := $ContextMenu

var _edited = []

var _edited_res: int = -1

func _ready():
	res_editor.changed.connect(_prop_changed)
	tabs.item_selected.connect(func(idx):
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

	tabs.clear()
	for r in _edited:
		tabs.add_item(r.resource_path)

	if _edited_res >= 0:
		tabs.select(_edited_res)

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

func context_menu(source: Node):
	var rect = Rect2(get_viewport().get_mouse_position(), Vector2.ZERO)
	ctx_menu.request(rect, source)

func _gui_input(e):
	if e is InputEventMouseButton and e.button_index == 2 and e.pressed and ctx_menu:
		context_menu(self)
