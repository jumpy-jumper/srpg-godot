extends MenuNode


export var x = 1280
export var y = 720

func on_pressed():
	.on_pressed()
	Game.settings["fullscreen"] = false
	Game.settings["resolution"] = Vector2(x, y)
	Game.apply_settings()
