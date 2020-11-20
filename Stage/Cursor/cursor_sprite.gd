extends AnimatedSprite


func _on_Cursor_position_changed() -> void:
	play("default")


func _on_AnimatedSprite_animation_finished() -> void:
	play("default")
