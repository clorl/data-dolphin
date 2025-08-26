class CommandTarget:
	var target: Variant

class Command:
	var name := "Base Command"
	var target: CommandTarget
	var id := -1

	func can_execute() -> bool:
		push_error("can_execute method on Command not implemented")
		return false

	func execute() -> bool:
		push_error("execute method on Command not implemented")
		return false

	func undo():
		pass

class Copy extends Command:
	func _init():
		name = "Copy"
