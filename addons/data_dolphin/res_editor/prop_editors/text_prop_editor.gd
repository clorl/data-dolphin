@tool
extends DM_PropEditor

@export var with_label := true:
	set(val):
		with_label = val
		if label_node:
			label_node.visible = val

@export var label_node: Control
@export var val_node: Control

var _propname
var _value

func set_name(v):
	_propname = v
	label_node.text = v

func set_value(v):
	_value = v
	val_node.text = str(v)

func _ready():
	val_node.focus_exited.connect(func(): 
		changed.emit(_propname, _value)
	)
