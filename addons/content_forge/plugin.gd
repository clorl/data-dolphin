# All plugin class_name prefixed with CF

@tool
extends EditorPlugin
const MainView = preload("./editor/main_view/main_view.tscn")

var main_view

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	Engine.set_meta("ContentForgePlugin", self)

	main_view = MainView.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_view)
	_make_visible(false)

func _exit_tree() -> void:
	if is_instance_valid(main_view):
		main_view.queue_free()
	Engine.remove_meta("ContentForgePlugin")

func _ready():
	pass

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if is_instance_valid(main_view):
		main_view.visible = visible
		if visible:
			main_view.refresh()

func _get_plugin_name() -> String:
	return "Content"

# func _get_plugin_icon() -> Texture2D:
# 	return load(get_plugin_path("/assets/icon.svg"))

## TODO implement func _handles(object) -> bool:

func get_plugin_path(append := ""):
	return get_script().resource_path.get_base_dir() + append


## Get the editor shortcut that matches an event
func get_editor_shortcut(event: InputEventKey) -> String:
	var shortcuts: Dictionary = get_editor_shortcuts()
	for key in shortcuts:
		for shortcut in shortcuts.get(key, []):
			if event.as_text().split(" ")[0] == shortcut.as_text().split(" ")[0]:
				return key
	return ""


func get_editor_shortcuts() -> Dictionary:
	var shortcuts: Dictionary = {
		toggle_comment = [
			_create_event("Ctrl+K"),
			_create_event("Ctrl+Slash")
		],
		delete_line = [
			_create_event("Ctrl+Shift+K")
		],
		move_up = [
			_create_event("Alt+Up")
		],
		move_down = [
			_create_event("Alt+Down")
		],
		save = [
			_create_event("Ctrl+Alt+S")
		],
		close_file = [
			_create_event("Ctrl+W")
		],
		find_in_files = [
			_create_event("Ctrl+Shift+F")
		],

		run_test_scene = [
			_create_event("Ctrl+F5")
		],
		text_size_increase = [
			_create_event("Ctrl+Equal")
		],
		text_size_decrease = [
			_create_event("Ctrl+Minus")
		],
		text_size_reset = [
			_create_event("Ctrl+0")
		]
	}

	var paths = EditorInterface.get_editor_paths()
	var settings

	## TOFIX make this work for any version
	if FileAccess.file_exists(paths.get_config_dir() + "/editor_settings-4.3.tres"):
		settings = load(paths.get_config_dir() + "/editor_settings-4.3.tres")
	elif FileAccess.file_exists(paths.get_config_dir() + "/editor_settings-4.tres"):
		settings = load(paths.get_config_dir() + "/editor_settings-4.tres")
	else:
		return shortcuts

	for s in settings.get("shortcuts"):
		for key in shortcuts:
			if s.name == "script_text_editor/%s" % key or s.name == "script_editor/%s" % key:
				shortcuts[key] = []
				for event in s.shortcuts:
					if event is InputEventKey:
						shortcuts[key].append(event)

	return shortcuts


func _create_event(string: String) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	var bits = string.split("+")
	event.keycode = OS.find_keycode_from_string(bits[bits.size() - 1])
	event.shift_pressed = bits.has("Shift")
	event.alt_pressed = bits.has("Alt")
	if bits.has("Ctrl") or bits.has("Command"):
		event.command_or_control_autoremap = true
	return event
