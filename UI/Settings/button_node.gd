extends SettingsNode


export(Array) var properties
export(Array) var values


func on_pressed():
	for i in range(min(len(properties), len(values))):
		Game.settings[properties[i]] = values[i]
	Game.apply_settings()
