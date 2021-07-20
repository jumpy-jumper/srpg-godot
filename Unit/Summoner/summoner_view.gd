extends UnitView


func _process(_delta):
	if not $DeathTweener.is_active():
		modulate.a = 1.0 if unit.alive else 0
	elif unit.alive:
		$DeathTweener.stop_all()
		modulate.a = 1.0
