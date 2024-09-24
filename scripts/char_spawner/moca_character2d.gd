@tool
extends CharacterBody2D
class_name Moca_Character2d

@export var speed : float = 100.0
@export var health : int = 100
@export var destroy_wait_time : float = 3.0
@export var flip : bool = false

var is_dead = false
enum animation_status { Idle, Run, Jump, Death }
var anima_state : int = animation_status.Idle
var anima_state_last : int = animation_status.Idle

#信号
signal character_dead
signal character_destroy


@export var begin : bool = false:
	set(arg1):
		print("CharSpawner_Character2d _init()")
		# 创建子节点
		var animated_sprite = Node2D.new()
		add_child(animated_sprite)
		animated_sprite.name = "AnimatedSprite2D"
		animated_sprite.owner = self
	
		
		var p = animated_sprite.get_parent()
		print("p.name: ",p.name)
	get:
		return begin

func _init():
	pass
	
	
	

	
func start(str : String):
	print("参数赋值")

	
	





func process(delta: float) -> void:
	self.character_move_control(delta)
	self.move_and_slide()
	
func get_direction() -> float:
	return 0
func get_jump(delta: float) -> void:
	pass
	
func character_move_control(delta: float) -> void:
	#重力控制
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction : float = 0
	
	if not self.is_dead:
		#跳跃
		self.get_jump(delta)
		#角色移动方向
		direction = self.get_direction()
		if direction:
			velocity.x = direction * self.speed
		else:
			velocity.x = move_toward(velocity.x, 0, self.speed)
			
		character_flip(self.animated_sprite_2d, direction)
	else:
		velocity.x = 0
	
	animation_status_ctrl(direction)
	animation_control(self.animated_sprite_2d)

func character_flip(animated_sprite: AnimatedSprite2D, dir : float) -> void:
	if dir > 0:
		self.flip = false
	elif dir < 0:
		self.flip = true
	
	if self.flip:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
		
func animation_status_ctrl(dir : float) -> void:
	if self.is_dead:
		self.anima_state = self.animation_status.Death
	else:
		if is_on_floor():
			if dir == 0:
				self.anima_state = self.animation_status.Idle
			else:
				self.anima_state = self.animation_status.Run
		else:
			self.anima_state = self.animation_status.Jump
func animation_control(animated_sprite: AnimatedSprite2D) -> void:
	if self.anima_state != self.anima_state_last:
		self.anima_state_last = self.anima_state
		if self.anima_state == self.animation_status.Idle:
			animated_sprite.play("idle")
		elif self.anima_state == self.animation_status.Run:
			animated_sprite.play("run")
		elif self.anima_state == self.animation_status.Jump:
			animated_sprite.play("jump")
		elif self.anima_state == self.animation_status.Death:
			animated_sprite.play("death")

func _on_character_destroy() -> void:
	print("character destroy")
	character_destroy.emit()
	queue_free()
	
func set_health(_health : int) -> void:
	self.health = self.health + _health
	print("health: ", self.health)
	if self.health <= 0 and not self.is_dead:
		print("character dead")
	
		self.is_dead = true
		character_dead.emit()
		
		#使用timer实现延迟事件绑定
		var timer : Timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = self.destroy_wait_time
		add_child(timer)
		timer.start()
		timer.timeout.connect(_on_character_destroy)
