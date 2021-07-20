extends Node2D
class_name UnitView


onready var unit = $".."


###############################################################################
#        Toasts                                                               #
###############################################################################

var physical_color = Color.lightcoral
var magic_color = Color.blue
var true_color = Color.white
var shield_damage_color = Color.goldenrod
var healing_color = Color.green
var shield_color = Color.goldenrod
var colors = [physical_color, magic_color, true_color, healing_color, shield_color, shield_damage_color]

var damage_toast = preload("res://Unit/damage_toast.tscn")


func get_damage_toast(amount, color):
	var toast = damage_toast.instance()
	toast.amount = amount
	toast.color = color
	return toast


func _on_Unit_damage_taken(amount, type):
	var toast = get_damage_toast(amount, colors[type])
	add_child(toast)


var targeting_toast = preload("res://Unit/targeting_toast.tscn")

func _on_Unit_damage_dealt(target, type):
	var toast = targeting_toast.instance()
	toast.attackee = target
	toast.gradient = toast.gradient.duplicate()
	toast.gradient.set_color(1, colors[type])
	add_child(toast)


###############################################################################
#        Death                                                                #
###############################################################################


const DEATH_TWEEN_DURATION = 0.5


func _on_Unit_dead(unit):
	$DeathTweener.interpolate_property(self, "modulate:a",
	0.75, 0, DEATH_TWEEN_DURATION,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$DeathTweener.start()


###############################################################################
#        Hovered                                                              #
###############################################################################


func _on_Unit_hovered():
	$Ranges.visible = true


func _on_Unit_unhovered():
	$Ranges.visible = false
