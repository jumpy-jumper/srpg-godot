extends Control
class_name StageUI


const FADE_IN_DURATION = 0.25


var operatable = false


func _ready():
	modulate.a = 0


func _process(delta):
	visible = modulate.a > 0


func show():
	$Tween.interpolate_property(self, "modulate:a",
		0, 1, FADE_IN_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func hide():
	$Tween.interpolate_property(self, "modulate:a",
		1, 0, FADE_IN_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
