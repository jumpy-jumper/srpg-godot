extends Node2D


export var duration = 0.5
export var travel = 200
export var x_spread = 25
export var y_spread = 25
export var y_step = 25

var amount = 0
var color = Color.black


func _ready():
	position.x += (randf() * x_spread) - (x_spread/2)
	position.y += (randf() * y_spread) - (y_spread/2)
	$Label.text = str(amount)
	$Label.modulate = color
	
	$TweenModulate.interpolate_property(self, "modulate:a",
	1, 0, duration,
	Tween.TRANS_BACK, Tween.EASE_OUT)
	$TweenModulate.start()
	
	$TweenPosition.interpolate_property(self, "position:y",
	position.y, position.y - travel, duration,
	Tween.TRANS_BACK, Tween.EASE_OUT)
	$TweenPosition.start()

	yield(get_tree().create_timer(duration), "timeout")
	
	queue_free()
