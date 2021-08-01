extends Menu


export(NodePath) var description = null


func _ready():
	description = get_node(description)


func _process(_delta):
	var size = Game.settings["resolution"]
	initial = "Fullscreen" if Game.settings["fullscreen"] else (str(size.x) + "x" + str(size.y))
	if description:
		if mouse_focus:
			description.text = mouse_focus.description if mouse_focus is SettingsNode else ""
		elif selected_node:
			description.text = selected_node.description if selected_node is SettingsNode else ""
		else:
			description.text = ""
