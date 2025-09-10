@tool
class_name DataContainer extends Node

const GEN_PATH = "res://_generated/"

@export_tool_button("Generate Resources") var generate_action = generate_scripts

func generate_scripts():
	# 1. Find all the TypeRef nodes in the tree and generate scripts for them
	# 2. Walk the tree to find similar structures and print a warning (or represent them as the same type?)
	# 3. Generate each top-level resource

	var reload_queue = []
	# One resource per top-level child
	for schema in get_children():
		if not schema is SchemaNode:
			continue
		var filename = schema.name.validate_filename().to_snake_case()
		var path = GEN_PATH + filename + ".gd"

		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_string("# Hello World")
			file.close()
		else:
			print("Error saving script. Could not open file at: ", path)

	EditorInterface.get_resource_filesystem().scan()

func parse_schema(node: SchemaNode, is_root=false) -> Array[String]:
	var content = []
	if is_root:
		content.push_back("class_name %s extends Resource" % node.name.validate_node_name())
	for child in get_children():
		content = content + parse_schema(child)
	pass
