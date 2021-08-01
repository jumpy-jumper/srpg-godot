extends MenuNode


func on_pressed():
	Game.settings["fullscreen"] = true
	Game.apply_settings()
