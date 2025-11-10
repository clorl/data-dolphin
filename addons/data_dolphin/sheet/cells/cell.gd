extends Control

enum CellMode {
	Read,
	Write
}

signal contents_edited(this: Control, new_contents)

@onready var read = $Read
@onready var write = $Write

var data

var mode := CellMode.Read:
	set(val):
		mode = val
		refresh()

func _ready():
	pass

func refresh():
	if mode == CellMode.Read:
		read.visible = true
		write.visible = false
	elif mode == CellMode.Write:
		read.visible = false
		write.visible = true
