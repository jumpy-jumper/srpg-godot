extends Control
class_name StageUI


const FADE_IN_DURATION = 0.125


var operatable = false


func _ready():
	visible = true
	modulate.a = 0


func show():
	operatable = true
	$Tween.interpolate_property(self, "modulate:a",
		0, 1, FADE_IN_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
		


func hide():
	operatable = false
	$Tween.interpolate_property(self, "modulate:a",
		1, 0, FADE_IN_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
