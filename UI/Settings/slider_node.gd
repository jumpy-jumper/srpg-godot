extends SettingsNode


export(String, MULTILINE) var property = ""

func _process(_delta):
	$HSlider.value = Game.settings[property] * $HSlider.max_value

func _on_HSlider_value_changed(value):
	Game.settings[property] = value / $HSlider.max_value
	Game.apply_settings()
