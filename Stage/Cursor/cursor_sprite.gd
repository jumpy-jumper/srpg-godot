extends AnimatedSprite


func _on_Cursor_position_changed():
	play("default")


func _on_AnimatedSprite_animation_finished() :
	play("default")
