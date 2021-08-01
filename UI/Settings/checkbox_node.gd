extends MenuNode

export var property = "settings_property"

func _process(_delta):
	$CheckBox.pressed = Game.settings[property]

func on_pressed():
	Game.settings[property] = not Game.settings[property]
	Game.apply_settings()
