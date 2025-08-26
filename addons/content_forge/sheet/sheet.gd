@tool
extends Control

const CELL_SIZE = Vector2(100, 21)
const HEADER_SIZE = Vector2(64, 24)
const BORDER_WIDTH = 1
const COLS = 20
const ROWS = 100

@export var header_cell_scene: PackedScene
@export var active_cell_scene: PackedScene
@export var header_drag_area_size := Vector2(24, 10) # The size of the area you grab to resize cols and rows

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

# foooo

func _ready():
	#script_changed.connect(_on_script_changed)
	if Engine.is_editor_hint() and not self.theme:
		var editor_theme = EditorInterface.get_editor_theme()
		self.theme = editor_theme
	custom_minimum_size = size_pixels
	rebuild()

func _gui_input(event: InputEvent) -> void:

	# if event is InputEventMouse:
	# 	match event.as_text():
	# 		"Ctrl+Mouse Wheel Up", "Command+Mouse Wheel Up":
	# 			self.font_size += 1
	# 			get_viewport().set_input_as_handled()
	# 		"Ctrl+Mouse Wheel Down", "Command+Mouse Wheel Down":
	# 			self.font_size -= 1
	# 			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pos = get_local_mouse_position()
			active_cell_node.visible = true
			active_cell_node.position = get_cell_at_pos(pos).position - Vector2.ONE * BORDER_WIDTH
			active_cell_node.size = get_cell_at_pos(pos).size + Vector2.ONE * BORDER_WIDTH
			queue_redraw()

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

func _on_script_changed():
	rebuild()
	print("Rebuilt")

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
	row_headers.position.y = HEADER_SIZE.y + BORDER_WIDTH

	for x in range(COLS):
		var cell = header_cell_scene.instantiate()
		if cell is Control:
			cell.custom_minimum_size = Vector2(CELL_SIZE.x, HEADER_SIZE.y)
			cell.text = char(KEY_A + (x % 25))
			col_headers.add_child(cell)
	for y in range(ROWS):
		var cell = header_cell_scene.instantiate()
		if cell is Control:
			cell.custom_minimum_size = Vector2(HEADER_SIZE.x, CELL_SIZE.y)
			cell.text = str(y+1)
			row_headers.add_child(cell)

	queue_redraw()
	print("Rebuilt")

func refresh():
	queue_redraw()

func get_cell_at_pos(pos: Vector2) -> Rect2:
	pos -= grid_offset
	var cell_id = Vector2i(pos / CELL_SIZE)
	if cell_id.x < 0 or cell_id.x >= COLS or cell_id.y < 0 or cell_id.y >= ROWS:
		return Rect2()
	var cell_pos = Vector2(cell_id) * CELL_SIZE
	return Rect2(cell_pos + grid_offset, CELL_SIZE)
