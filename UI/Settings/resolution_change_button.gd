extends MenuNode


export var x = 1280
export var y = 720

func on_pressed():
	.on_pressed()
	OS.window_fullscreen = false
	OS.set_window_size(Vector2(x, y))  
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
