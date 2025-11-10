# All plugin class_name prefixed with DD

@tool
extends EditorPlugin
const MainView = preload("./editor/resource_editor_view.tscn")

var main_view

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	Engine.set_meta("DataManager", self)

	main_view = MainView.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_view)
	_make_visible(false)

func _exit_tree() -> void:
	if is_instance_valid(main_view):
		main_view.queue_free()
	Engine.remove_meta("DataManager")

func _ready():
	_make_visible(false)
	pass

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if is_instance_valid(main_view):
		main_view.visible = visible
		if visible:
			main_view.refresh()

func _get_plugin_name() -> String:
	return "Data"

func _get_plugin_icon() -> Texture2D:
	return load(get_plugin_path("/assets/icon.svg"))

## TODO implement func _handles(object) -> bool:
func _handles(object):
	if not object is Resource:
		return false

	if object is PackedScene or \
		object is Script:
		return false

	return true

func _edit(object):
	if is_instance_valid(main_view):
		if main_view.open(object):
			_make_visible(true)

func get_plugin_path(append := ""):
	return get_script().resource_path.get_base_dir() + append
