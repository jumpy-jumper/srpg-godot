extends Skill

var targeting_toast = preload("res://Unit/targeting_toast.tscn")

var voices = [
	preload("res://Voices/CN_025.ogg"),
	preload("res://Voices/CN_026.ogg"),
	preload("res://Voices/CN_027.ogg"),
	preload("res://Voices/CN_028.ogg"),
]

func activate():
	.activate()
	unit.stage.get_selected_summoner().recover_faith(1)
	
	var skill_range = unit.get_stat("skill_range", base_skill_range)
	var possible_targets = []
	possible_targets = unit.get_units_in_range_of_type(skill_range, unit.get_type_of_enemy())
	
	for target in select_targets(possible_targets):
		target.apply_damage(unit.get_stat("atk", unit.base_atk) * 1.8, \
			unit.get_stat("damage_type", unit.get_basic_attack().damage_type))
		target.display_toasts()
	
		var toast = targeting_toast.instance()
		toast.attacker = unit
		toast.attackee = target
		toast.gradient = toast.gradient.duplicate()
		toast.gradient.set_color(1, unit.colors[unit.get_basic_attack().damage_type])
		unit.targeting_toasts.append(toast)
		unit.display_toasts()
	
	if Game.settings["nils_voice_lines"]:
		var audio = AudioStreamPlayer2D.new()
		unit.add_child(audio)
		audio.stream = voices[randi() % len(voices)]
		audio.pitch_scale = 1.35
		audio.play()
