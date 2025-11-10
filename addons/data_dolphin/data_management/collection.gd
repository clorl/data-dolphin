class_name ResourceCollection extends Resource

@export var resources: Array[Resource]

func size():
	return resources.size()

func get_resources_props() -> Dictionary:
	var proplist = {}
	for r in resources:
		var rid = r.get_rid()
		proplist[rid] = r.get_property_list()
	return proplist
