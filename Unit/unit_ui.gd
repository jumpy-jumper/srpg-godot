extends Control


func _process(delta):
	var unit = $".."
	$"SP".text = str(unit.sp) if unit.sp > 0 else "������-"
	$Health.text = str(unit.hp)
