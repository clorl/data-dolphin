@tool
class_name DDSheetHeader
extends Control

const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

signal pressed(node: DDSheetHeader)

var is_row = false:
var index = -1:
	set(value):
		index = value
		if is_row:
			$Button.text = str(index)
			return
		var max_iter = 10_000
		var cur = value
		var result = ""
		var iter = 0
		while cur >= 0:
			iter += 1
			if iter > max_iter:
				return
			result = LETTERS[cur % 26]
			cur /= 26
			cur -= 1
		$Button.text = result
var drag_margin_pixels = 10

func _gui_input(e):
	if e is InputEventMouse:
		pass

func _on_button_pressed():
	pressed.emit(self)
