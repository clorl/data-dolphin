@tool
extends Control

enum ResizeState {
	NONE,
	COL,
	ROW
}

const CELL_SIZE = Vector2(100, 21)
const HEADER_SIZE = Vector2(64, 24)
const BORDER_WIDTH = 1
const COLS = 20
const ROWS = 100

@export var header_cell_scene: PackedScene
@export var active_cell_scene: PackedScene
@export var header_separator_scene: PackedScene
@export var header_drag_area_size := Vector2(10, 24) # The size of the area you grab to resize cols and rows
@export var selection_stylebox: StyleBox

var cell_data := {}
var cell_format := {}

var size_pixels:
	get:
		return Vector2(CELL_SIZE.x * COLS, CELL_SIZE.y * ROWS) + grid_offset
var grid_offset:
	get:
		return HEADER_SIZE + Vector2.ONE * BORDER_WIDTH

var pos = Vector2(150, 72)

var active_cell_node: Control

@onready var col_headers: HBoxContainer = $Cols
@onready var row_headers: VBoxContainer = $Rows

var _resize_state = ResizeState.NONE
var _resize_start_pos = Vector2.ZERO
var _resize_target: Control = null
var _resize_delta = 0

var _selection: Array[Rect2i] = []

func _ready():
	if Engine.is_editor_hint() and not self.theme:
		var editor_theme = EditorInterface.get_editor_theme()
		if editor_theme:
			self.theme = editor_theme
	custom_minimum_size = size_pixels
	rebuild()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				return
				var clicked_cell = get_cell_at_pos(get_local_mouse_position())
				_selection.clear()
				_selection.push_back(Rect2i(clicked_cell, Vector2i.ZERO))
				refresh()
			else:
				if _resize_state != ResizeState.NONE:
					_resize_state = ResizeState.NONE

func _draw():
	# Background
	var style = theme.get_stylebox("normal", "PanelBackgroundButton")
	style.draw(get_canvas_item(), Rect2(grid_offset, size_pixels))

	# Cell borders
	var border_color = theme.get_color("contrast_color_1", "Editor")
	var offset_horiz = Vector2(grid_offset.x , 0)
	var offset_vert = Vector2(0, grid_offset.y)
	for x in range(COLS+1):
		draw_line(
		Vector2(x, 0) * CELL_SIZE + grid_offset,
		Vector2(x, ROWS) * CELL_SIZE + grid_offset,
		border_color, BORDER_WIDTH
		)
	for y in range(ROWS+1):
		draw_line(
		Vector2(0, y) * CELL_SIZE + grid_offset,
		Vector2(COLS, y) * CELL_SIZE + grid_offset,
		border_color, BORDER_WIDTH
		)

	# Selection 
	if _selection.size():
		for sel in _selection:
			var rect = get_cells_rect(sel)
			print(str(rect))
			draw_style_box(selection_stylebox, rect)


	# Resize indicator
	var mouse = get_local_mouse_position()

	match _resize_state:
		ResizeState.COL:
			draw_line(
				Vector2(mouse.x, 0),
				Vector2(mouse.x, (ROWS + 1) * CELL_SIZE.y),
				theme.get_color("contrast_color_2", "Editor"),
				BORDER_WIDTH * 4
			)
		ResizeState.ROW:
			draw_line(
				Vector2(0, mouse.y),
				Vector2((COLS + 1) * CELL_SIZE.x, mouse.y),
				theme.get_color("contrast_color_2", "Editor"),
				BORDER_WIDTH * 4
			)

func _on_header_sep_gui_input(event, separator: Control):
	if _resize_target != separator: return
	_resize_delta = _resize_target.get_local_mouse_position()
	refresh()

func _on_header_sep_mouse_down(separator: Control):
	var is_vertical = separator.get_meta("is_vertical", false)
	_resize_state = ResizeState.ROW if is_vertical else ResizeState.COL
	_resize_target = separator
	refresh()

func _on_header_sep_mouse_up(separator: Control):
	if _resize_target == separator:
		_resize_state = ResizeState.NONE
		_resize_target = null
		refresh()

func _make_header_separator(is_vertical: bool):
	var sep = header_separator_scene.instantiate()
	sep.z_index = 100
	sep.set_meta("is_vertical", is_vertical)
	sep.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	if is_vertical:
		sep.custom_minimum_size.y = header_drag_area_size.y
		sep.mouse_default_cursor_shape = Control.CursorShape.CURSOR_VSIZE
	else:
		sep.custom_minimum_size.x = header_drag_area_size.x
		sep.mouse_default_cursor_shape = Control.CursorShape.CURSOR_HSIZE
	sep.button_down.connect(func():
		_on_header_sep_mouse_down(sep)
	)
	sep.button_up.connect(func():
		_on_header_sep_mouse_up(sep)
	)
	sep.gui_input.connect(func(e):
		_on_header_sep_gui_input(e, sep)
	)
	return sep

func _on_header_pressed(node: Control):
	if node.has_meta("col_idx"):
		print("foo")
		_selection.clear()
		_selection.push_back(Rect2i(0, node.get_meta("col_idx"), ROWS, node.get_meta("col_idx")))
		print(str(_selection))
	elif node.has_meta("row_idx"):
		_selection.clear()
		_selection.push_back(Rect2i(node.get_meta("row_idx"), 0, node.get_meta("row_idx"), COLS))
	pass

func rebuild():
	# Active cell
	if active_cell_node:
		active_cell_node.queue_free()
	active_cell_node = active_cell_scene.instantiate()
	add_child(active_cell_node)
	active_cell_node.visible = false

	# Headers
	for child in col_headers.get_children(): child.queue_free()
	for child in row_headers.get_children(): child.queue_free()

	col_headers.position.x = HEADER_SIZE.x + BORDER_WIDTH
	col_headers.add_theme_constant_override("separation",-0.5 * header_drag_area_size.x)
	row_headers.position.y = HEADER_SIZE.y + BORDER_WIDTH
	row_headers.add_theme_constant_override("separation",-0.5 * header_drag_area_size.y)

	for x in range(COLS):
		var cell = header_cell_scene.instantiate()
		if cell is Control:
			cell.custom_minimum_size = Vector2(CELL_SIZE.x, HEADER_SIZE.y)
			cell.text = char(KEY_A + (x % 25))
			cell.set_meta("col_idx", x)
			cell.pressed.connect(func():
				_on_header_pressed(cell)
			)
			col_headers.add_child(cell)
			col_headers.add_child(_make_header_separator(false))
	for y in range(ROWS):
		var cell = header_cell_scene.instantiate()
		if cell is Control:
			cell.custom_minimum_size = Vector2(HEADER_SIZE.x, CELL_SIZE.y)
			cell.text = str(y+1)
			cell.set_meta("row_idx", y)
			cell.pressed.connect(func():
				_on_header_pressed(cell)
			)
			row_headers.add_child(cell)
			row_headers.add_child(_make_header_separator(true))

	refresh()

func refresh():
	active_cell_node.visible = false
	if active_cell_node and _selection.size():
		active_cell_node.visible = true
		var last = _selection[_selection.size() - 1]
		var rect = get_cell_rect(last.end)
		active_cell_node.position = rect.position
		active_cell_node.custom_minimum_size = rect.size
	queue_redraw()

# Converts a local position of the Control to the corresponding cell in sheet coordinates
func get_cell_at_pos(pos: Vector2) -> Vector2i:
	pos -= grid_offset
	return Vector2i(pos / CELL_SIZE)

func get_cell_rect(cell_id: Vector2i) -> Rect2:
	if cell_id.x < 0 or cell_id.x >= COLS or cell_id.y < 0 or cell_id.y >= ROWS:
		return Rect2()
	var cell_pos = Vector2(cell_id) * CELL_SIZE
	return Rect2(cell_pos + grid_offset, CELL_SIZE)

# Converts a range of cells in sheet coordinates to the bounding rectangle relative to the Control
func get_cells_rect(rect: Rect2i) -> Rect2:
	return Rect2(get_cell_rect(rect.position).position, get_cell_rect(rect.end).size)
