extends MenuNode


func on_pressed():
	.on_pressed()
	Game.level_to_load = load("res://Levels/" + name + ".tscn")
	get_tree().change_scene("res://Stage/stage.tscn")
