local ok, overseer = pcall(require, "overseer")

if not ok then
	print("Overseer not setup")
	return
end

overseer.new_task {
	cmd = "godot",
	args = { "-e", "./project.godot" },
	name = "Godot Editor"
}
