extends UnitView


func _ready():
	$Facing.visible = true


func _process(_delta):
	visible = unit.alive
	
	var activatable_skill = unit.get_first_activatable_skill()
	$Ready.visible = unit.alive and (activatable_skill.is_available() if activatable_skill else false)
	
	if not $DeathTweener.is_active():
		modulate.a = 0.5 if unit.previewing else (1.0 if unit.alive else 0)
	elif unit.alive:
		$DeathTweener.stop_all()
		modulate.a = 1.0
	
	update_facing()


func _on_Unit_hovered():
	$Ranges.visible = $Ranges.visible or unit.waiting_for_facing


export var standby_alpha = 0.5
onready var default_alpha = $"Facing/Right".modulate.a

func update_facing():
	var children = $Facing.get_children()
	
	var cur = children[posmod(unit.facing, 360) / 90]
	for node in children:
		if node == cur:
			node.modulate.a = 1 if unit.waiting_for_facing else default_alpha
		else:
			node.modulate.a = standby_alpha if unit.waiting_for_facing else 0
