extends CharacterBody2D
class_name MyCharacter

@export var SPEED = 100.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var health : int = 100
@export var destroy_wait_time : int = 3
@export var flip : bool = false

var is_dead = false
enum animation_status { Idle, Run, Jump, Death }
var anima_state : int = animation_status.Idle
var anima_state_last : int = animation_status.Idle
#信号
signal character_dead
signal character_destroy

func _physics_process(delta: float) -> void:
	
	character_move_control(delta)
	move_and_slide()

func get_direction() -> float:
	return 0
func get_jump(delta: float) -> void:
	pass
	
func character_move_control(delta: float) -> void:
	#重力控制
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction : float = 0
	
	if not is_dead:
		#跳跃
		get_jump(delta)
		#角色移动方向
		direction = get_direction()
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		character_flip(animated_sprite_2d, direction)
	else:
		velocity.x = 0
	
	animation_status_ctrl(direction)
	animation_control(animated_sprite_2d)

func character_flip(animated_sprite: AnimatedSprite2D, dir : float) -> void:
	if dir > 0:
		flip = false
	elif dir < 0:
		flip = true
	
	if flip:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
		
func animation_status_ctrl(dir : float) -> void:
	if is_dead:
		anima_state = animation_status.Death
	else:
		if is_on_floor():
			if dir == 0:
				anima_state = animation_status.Idle
			else:
				anima_state = animation_status.Run
		else:
			anima_state = animation_status.Jump
func animation_control(animated_sprite: AnimatedSprite2D) -> void:
	if anima_state != anima_state_last:
		anima_state_last = anima_state
		if anima_state == animation_status.Idle:
			animated_sprite.play("idle")
		elif anima_state == animation_status.Run:
			animated_sprite.play("run")
		elif anima_state == animation_status.Jump:
			animated_sprite.play("jump")
		elif anima_state == animation_status.Death:
			animated_sprite.play("death")

func _on_character_destroy() -> void:
	print("character destroy")
	character_destroy.emit()
	queue_free()
	
func set_health(_health : int) -> void:
	health = health + _health
	print("health: ", health)
	if health <= 0 and not is_dead:
		print("character dead")
	
		is_dead = true
		character_dead.emit()
		
		#使用timer实现延迟事件绑定
		var timer : Timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = destroy_wait_time
		add_child(timer)
		timer.start()
		timer.timeout.connect(_on_character_destroy)
