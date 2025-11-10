@tool
extends FlowContainer

signal changed(propname, new_val)

@export var PropEditor: PackedScene
@export var min_prop_size: Vector2
var resource:
	set(val):
		resource = val
		rebuild()

var hidden_props = ["resource_path", "resource_name", "script", "resource_local_to_scene", "metadata/_custom_type_script"]

var _props = {}

func rebuild():
	for c in get_children():
		c.queue_free()
	_props = {}
	for p in _get_props():
		var inst = PropEditor.instantiate()
		inst.label = p.name
		inst.value = p.value
		inst.changed.connect(_prop_changed)
		inst.custom_minimum_size = min_prop_size
		_props[p.name] = p
		_props[p.name].control = inst
		add_child(inst)

func refresh():
	for p in _props.values():
		if not p.control:
			continue
		p.control.label = p.name
		p.control.value = resource[p.name]

func _prop_changed(propname, new_val):
	changed.emit(propname, new_val)

func _get_props():
	return resource.get_property_list() \
	.filter(func(p):
		return p.usage & PropertyUsageFlags.PROPERTY_USAGE_EDITOR and not p.name in hidden_props
	) \
	.map(func(p):
		p["value"] = resource.get(p.name)
		return p
	)
