@tool
class_name DM_PropEditor extends Control

signal changed(propname: String, new_val)

@export var with_label := true:
	set(val):
		with_label = val
		$Box/Label.visible = val

@export var label_node: Control
@export var val_node: Control

var label: String :
	set(v):
		label = v
		label_node.text = v
	get:
		return label
var value:
	set(v):
		value = v
		if val_node.text != str(v):
			val_node.text = str(v)
	get:
		return val_node.text

func _ready():
	val_node.focus_exited.connect(func(): 
		changed.emit(label, value)
	)
