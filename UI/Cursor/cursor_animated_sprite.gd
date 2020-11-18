extends AnimatedSprite


func _on_AnimatedSprite_animation_finished() -> void:
	play("default")
