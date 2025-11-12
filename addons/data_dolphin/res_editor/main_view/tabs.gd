@tool
extends ItemList

signal right_click(source: Node)

func _ready():
	item_clicked.connect(_item_clicked)

func _item_clicked(idx: int, pos: Vector2, button: int):
	if button == 2:
		right_click.emit(self)

# type: string
# args: Array
# callback: Callable
func _get_context_menu():
	return [
		{ "type": "item", "args": [ "Close", -1, Key.KEY_W ], "callback": cb },
		{ "type": "item", "args": [ "Close others" ], "callback": cb }
	]

func cb():
	print("Hello")
