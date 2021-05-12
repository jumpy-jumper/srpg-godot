extends Control


func _process(delta):
	var unit = $".."
	$"SP".text = str($"..".sp) if $".." is Summoner else ""
	$Health.text = str(unit.hp) if not $".." is Summoner else ""
