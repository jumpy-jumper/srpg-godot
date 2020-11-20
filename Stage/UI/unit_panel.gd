class_name UnitPanel
extends Node2D


var current : bool = false
var cur_unit: Unit

onready var _sprite: AnimatedSprite = $"Unit Sprite"
onready var _initiative_label: Label = $"Initiative Label"
onready var _health_label: Label = $"Health Label"
onready var _current: Node2D = $"Current"

func _process(_delta: float) -> void:
	if cur_unit:
		visible = true
		if _sprite.frames != cur_unit.get_node("Unit Sprite").frames:
			_sprite.frames = cur_unit.get_node("Unit Sprite").frames
		if _sprite.animation != cur_unit.get_node("Unit Sprite").animation:
			_sprite.animation = cur_unit.get_node("Unit Sprite").animation
		_initiative_label.text = cur_unit.get_node("Initiative Label").text
		_initiative_label.modulate = cur_unit.get_node("Initiative Label").modulate
		_health_label.text = cur_unit.get_node("Health Label").text
		_health_label.modulate = cur_unit.get_node("Health Label").modulate
		_current.visible = current
	else:
		visible = false
