extends Skill

var voices = [
	preload("res://Voices/CN_025.ogg"),
	preload("res://Voices/CN_026.ogg"),
	preload("res://Voices/CN_027.ogg"),
	preload("res://Voices/CN_028.ogg"),
]

func activate():
	.activate()
	unit.stage.get_selected_summoner().recover_faith(1)
	
	deal(unit.get_stat("atk", unit.base_atk) * 1.8)
	
	if Game.settings["nils_voice_lines"]:
		var audio = AudioStreamPlayer2D.new()
		unit.add_child(audio)
		audio.stream = voices[randi() % len(voices)]
		audio.pitch_scale = 1.35
		audio.play()
