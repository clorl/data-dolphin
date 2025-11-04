@tool
# Makes the target control resizable
class_name DM_Resizable extends Control

# TODO: Use @GlobalScope Side/Corner 
enum Direction {
	None = 0,
	Top = 1,
	Right = 1 << 1,
	Down = 1 << 2,
	Left = 1 << 3,
	TopRight = 1 | 2,
	TopLeft = 1 | 8,
	DownRight = 4 | 2,
	DownLeft = 4 | 8,
}

enum ResizeEvent {
	Never,    ## Not resized, this node can be used to detect input on border of a Control
	OnEnd,    ## The size will be updated when the resizing is finished
	OnUpdate  ## The size will update each frame of the resize
}

enum ResizeMode {
	Size,
	CustomMinimumSize
}

signal resize_drag_started(node: Control, direction: int, mouse_pos: Vector2)
signal resize_drag_updated(node: Control, direction: int, delta: Vector2)
signal resize_drag_finished(node: Control, direction: int, delta: Vector2)


@export var target: Control ## What control to make resizable
@export_flags("Top:1", "Right:2" ,"Down:4", "Left:8") var allowed_resize = 0 ## On which sides can the control be resized
@export var resize_event: ResizeEvent ## When should the target node be resized
@export var resize_mode: ResizeMode ## What property to use for resizing
@export var set_grow_dir := false ## TODO: Should resizing take care of the GrowDirection property
@export var resize_margin_px = 12

@export var debug = false

@export_group("Style")
@export var cursor_base       := Control.CursorShape.CURSOR_ARROW
@export var cursor_resize_h   := Control.CursorShape.CURSOR_HSIZE
@export var cursor_resize_v   := Control.CursorShape.CURSOR_VSIZE
@export var cursor_resize_ne  := Control.CursorShape.CURSOR_BDIAGSIZE
@export var cursor_resize_nw  := Control.CursorShape.CURSOR_FDIAGSIZE

var _border_rects = {}
var _local_rect: Rect2
var _hovered_border := 0
var _resize_state := 0
var _resize_start_mousepos := Vector2.ZERO
var _resize_original_rect = Rect2()

func _get_configuration_warnings():
	if not target:
		return ["You didn't specify which node to make resizable (target)"]
	else:
		return []

func _ready():
	position = Vector2.ZERO
	scale = Vector2.ONE
	rotation = 0
	if not target and get_parent() is Control:
		target = get_parent()
	_reset()

func _reset():
	var s = target.size if resize_mode == ResizeMode.Size else target.custom_minimum_size
	_local_rect = Rect2(Vector2.ZERO, s)
	if allowed_resize & Direction.Top:
		_border_rects[Direction.Top] = Rect2(0.0, 0.0, s.x, resize_margin_px)

	if allowed_resize & Direction.Right:
		_border_rects[Direction.Right] = Rect2(s.x - resize_margin_px, 0.0, resize_margin_px, s.y)

	if allowed_resize & Direction.Down:
		_border_rects[Direction.Down] = Rect2(0.0, s.y - resize_margin_px, s.x, resize_margin_px)

	if allowed_resize & Direction.Left:
		_border_rects[Direction.Left] = Rect2(0.0, 0.0, resize_margin_px, s.y)

func _input(event):
	if event is InputEventMouse:
		var mouse = get_local_mouse_position()

		# Move
		if event is InputEventMouseMotion:
			_hovered_border = 0
			for k in _border_rects.keys():
				var r = _border_rects[k]
				if r.has_point(mouse):
					_hovered_border |= k

			if _resize_state:
				# Resize update
				get_viewport().set_input_as_handled()
				resize_drag_updated.emit(target, _resize_state, mouse - _resize_start_mousepos)
				if resize_event == ResizeEvent.OnUpdate:
					resize(_resize_state, mouse - _resize_start_mousepos)
				if debug:
					print("Resize Updated - dir: %s delta: %s" % [_resize_state, mouse - _resize_start_mousepos])
			elif _hovered_border and debug:
				print("Hovering border: %s" % [_hovered_border])

		# Click
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _hovered_border != _resize_state:
					# Start resize
					_resize_state = _hovered_border
					get_viewport().set_input_as_handled()
					_resize_start_mousepos = mouse
					_resize_original_rect = Rect2(target.position, target.size)
					resize_drag_started.emit(target, _resize_state, mouse)
					if debug:
						print("Resize Started - dir: %s pos: %s" % [_resize_state, mouse])
			elif _resize_state:
				# Stop resize
				get_viewport().set_input_as_handled()
				resize_drag_finished.emit(target, _resize_state, mouse - _resize_start_mousepos)
				if resize_event == ResizeEvent.OnEnd or resize_event == ResizeEvent.OnUpdate:
					resize(_resize_state, mouse - _resize_start_mousepos)
				_reset()
				_resize_state = 0
				if debug:
					print("Resize Finished - dir: %s delta: %s" % [_resize_state, mouse - _resize_start_mousepos])

		if debug:
			queue_redraw()
		if not _resize_state:
			_set_cursor(_hovered_border)

func _draw():
	if not debug: return
	draw_set_transform(-position)
	for k in _border_rects.keys():
		var r = _border_rects[k]
		draw_rect(r, Color.YELLOW if _hovered_border & k else Color.BLUE, false, 1.0, true)

func _set_cursor(dir: int):
	var c = cursor_base
	if dir == Direction.Top or dir == Direction.Down:
		c = cursor_resize_v
	elif dir == Direction.Right or dir == Direction.Left:
		c = cursor_resize_h
	elif dir == Direction.TopRight or dir == Direction.DownLeft:
		c = cursor_resize_ne
	elif dir == Direction.DownRight or dir == Direction.TopLeft:
		c = cursor_resize_nw
	if c != null:
		target.mouse_default_cursor_shape = c
	else:
		push_warning("Got null when tried to set resize cursor on node %s, Direction: %s" % [str(self), str(dir)])

## Apply resizing to the parent
func resize(dir: int, delta: Vector2):
	var rect = _resize_original_rect
	rect.position = target.position
	if dir & Direction.Top:
		rect = rect.grow_side(Side.SIDE_TOP, delta.y)
		rect.position.y += delta.y
	if dir & Direction.Right:
		rect = rect.grow_side(Side.SIDE_RIGHT, delta.x)
	if dir & Direction.Down:
		rect = rect.grow_side(Side.SIDE_BOTTOM, delta.y)
	if dir & Direction.Left:
		rect = rect.grow_side(Side.SIDE_LEFT, delta.x)
		rect.position.x += delta.x
	target.position = rect.position
	match resize_mode:
		ResizeMode.Size:
			target.size = rect.size
		ResizeMode.CustomMinimumSize:
			target.custom_minimum_size = rect.size
