@tool
class_name DM_SheetHeader extends Button

signal resize_drag_started(node: Control, side: int)
signal resize_drag_updated(node: Control, side: int, delta: Vector2)
signal resize_drag_finished(node: Control, side: int, delta: Vector2)

@export var resize_margin_px = 12
@export var cursor_resizeh: CursorShape
@export var cursor_resizev: CursorShape
@export var allow_resize_horizontal = false
@export var allow_resize_vertical = false
@export var debug = false

var _hrect: Rect2
var _vrect: Rect2
var _local_rect: Rect2

var _border_rects: Array[Rect2] = [] #Clockwise
var _hovered_rect := -1
var _resize_state := -1
var _resize_start_mousepos := Vector2.ZERO

func _ready():
	_local_rect = Rect2(Vector2.ZERO, size)
	_border_rects.push_back(Rect2(resize_margin_px, 0.0, size.x - resize_margin_px * 2, resize_margin_px))
	_border_rects.push_back(Rect2(size.x - resize_margin_px, resize_margin_px, resize_margin_px, size.y - resize_margin_px * 2.0))
	_border_rects.push_back(Rect2(resize_margin_px, size.y - resize_margin_px, size.x - resize_margin_px * 2, resize_margin_px))
	_border_rects.push_back(Rect2(0.0, resize_margin_px, resize_margin_px, size.y - resize_margin_px * 2.0))
	queue_redraw()


func _input(event):
	if event is InputEventMouse:
		var mouse = get_local_mouse_position()
		var i = 0
		_hovered_rect = -1
		for r in _border_rects:
			if i % 2 == 0 and not allow_resize_vertical: continue
			if i % 2 != 0 and not allow_resize_horizontal: continue
			if r.has_point(mouse):
				_hovered_rect = i
				break
			i += 1
		if _hovered_rect <= -1:
			mouse_default_cursor_shape = 0
		else:
			if cursor_resizeh and _hovered_rect % 2 != 0:
				mouse_default_cursor_shape = cursor_resizeh
			elif cursor_resizev:
				mouse_default_cursor_shape = cursor_resizev

		if _resize_state >= 0:
			resize_drag_updated.emit(self, _resize_state, mouse - _resize_start_mousepos)
			print("Drag update")

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if _resize_state != _hovered_rect:
				if _resize_state <= -1 and event.pressed:
					_resize_state = _hovered_rect
					resize_drag_finished.emit(self, _resize_state)
					print("Drag Start")
			if not event.pressed and _resize_state > -1:
				_resize_start_mousepos = mouse
				resize_drag_started.emit(self, _resize_state, mouse - _resize_start_mousepos)
				_resize_state = -1
				print("Drag End")

		queue_redraw()

func _draw():
	if not debug: return
	var i = 0
	for r in _border_rects:
		draw_rect(r, Color.YELLOW if _hovered_rect == i else Color.BLUE)
		i += 1
