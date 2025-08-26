@tool
extends Button

var is_vertical = false:
	set(value):
		is_vertical = value
		_update_resize_handle()

var handle_size: float:
	set(value):
		handle_size = value
		_update_resize_handle()

func _ready():
	queue_redraw()

func _update_resize_handle():
	if is_vertical:
		$ResizeHandle.set_anchors_preset(LayoutPreset.PRESET_RIGHT_WIDE)
		$ResizeHandle.mouse_default_cursor_shape = CursorShape.CURSOR_VSIZE
		$ResizeHandle.custom_minimum_size.y = handle_size
		$ResizeHandle.position.y = get_rect().end.y + handle_size/2
	else:
		$ResizeHandle.set_anchors_preset(LayoutPreset.PRESET_BOTTOM_WIDE)
		$ResizeHandle.mouse_default_cursor_shape = CursorShape.CURSOR_HSIZE
		$ResizeHandle.custom_minimum_size.x = handle_size
		$ResizeHandle.position.x = get_rect().end.x + handle_size/2
	queue_redraw()

func _draw():
	draw_rect(get_rect(), Color.RED)
