@tool
class_name DM_ContextMenu extends PopupMenu

# Ctx menu item schema 
# type: string
# args: Array
# callback: Callable

var _callbacks = []

func _ready():
	index_pressed.connect(_index_pressed)

func _index_pressed(idx: int):
	if _callbacks.size() < idx - 1:
		return
	_callbacks[idx].call()

func request(rect: Rect2, caller: Node):
	if not caller.has_method("_get_context_menu"):
		return
	popup_on_parent(rect)
	var items = caller._get_context_menu()
	if items.size() <= 0:
		return
	clear()
	for elt in items:
		var method = "add_" + elt.type
		if not has_method(method):
			continue
		self[method].callv(elt.args)
		_callbacks.append(elt.callback)
