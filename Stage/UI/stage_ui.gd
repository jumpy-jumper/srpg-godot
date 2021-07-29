extends Control
class_name StageUI


const FADE_IN_DURATION = 0.125


var operatable = false


func _ready():
	visible = true
	modulate.a = 0
	for child in get_children():
		if child is NavigatableMenu:
			child.operatable = false
			child.selected_node = child.get_node(child.initial)


func show():
	operatable = true
	$Tween.interpolate_property(self, "modulate:a",
		0, 1, FADE_IN_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	for child in get_children():
		if child is NavigatableMenu:
			child.operatable = true
			child.selected_node = child.get_node(child.initial)
		


func hide():
	operatable = false
	for child in get_children():
		if child is NavigatableMenu:
			child.operatable = false
	$Tween.interpolate_property(self, "modulate:a",
		1, 0, FADE_IN_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
