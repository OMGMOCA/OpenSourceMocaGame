extends Node2D

@export var is_play : bool = false:
	set(value):
		is_play = value
		anima_state_changed()
	get:
		return is_play
@export var is_right : bool = false:
	set(value):
		is_right = value
		anima_state_changed()
	get:
		return is_right

func anima_state_changed() -> void:
	if is_play:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.pause()
	
	if is_right:
		$AnimatedSprite2D.speed_scale = 1
	else:
		$AnimatedSprite2D.speed_scale = -1
