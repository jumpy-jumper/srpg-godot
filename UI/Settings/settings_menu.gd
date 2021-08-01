extends Menu


func _process(_delta):
	var size = Game.settings["resolution"]
	initial = "Fullscreen" if Game.settings["fullscreen"] else (str(size.x) + "x" + str(size.y))
