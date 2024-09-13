extends Area2D

@export var sprite : Sprite2D = find_child("Sprite2D")
@export var timer : Timer = find_child("Timer")
@export var wait_time : float = 3

	
func on_body_entered(body: Node2D) -> void:
	print("trigger")
	
	sprite.visible = true
	timer.start()
	pass # Replace with function body.


func on_timer_timeout() -> void:
	sprite.visible = false
	pass # Replace with function body.


func _ready() -> void:
	self.body_entered.connect(on_body_entered)
	timer.timeout.connect(on_timer_timeout)
	timer.wait_time = wait_time
