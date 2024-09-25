extends MocaCharacter2d

@export var jump_speed : float = -180 
@export var max_jump_time : float = 0.5  
@export var jump_max_force : float = -17
@export var jump_min_force : float = 0.0


var jump_time : float = 0.0
var is_jumping : bool = false
var jump_input_time : float = 0
var jump_input_time_max : float = 0.1
var is_jump_input : bool = false


func get_direction() -> float:
	var direction := Input.get_axis("move_left", "move_right")
	return direction
	
func get_jump(delta : float) -> void:
	#如果角色在按下跳跃按钮后的0.1s内落地，都会执行跳跃功能
	if Input.is_action_just_pressed("jump"):
		is_jump_input = true
		jump_input_time = 0
	
	if is_jump_input and is_on_floor():
		is_jump_input = false
		is_jumping = true
		jump_time = 0
		velocity.y = jump_speed
	if Input.is_action_just_released("jump"):
		is_jumping = false
	
	var jump_force : float = 0
	
	if is_jump_input:
		jump_input_time += delta
		if jump_input_time > jump_input_time_max:
			is_jump_input = false
			
	#如果玩家长按跳跃键，会减缓重力的影响，从而跳的更高
	if is_jumping:
		jump_time += delta
		if jump_time > max_jump_time:
			jump_time = max_jump_time
		jump_force = lerp(jump_max_force, jump_min_force, jump_time / max_jump_time)
		velocity.y += jump_force
		
func character_flip(animated_sprite: AnimatedSprite2D, dir : float) -> void:
	super(animated_sprite, dir) #super()用于复写父类方法的同时，继承原有的功能
	
func _physics_process(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("interact"):
		pass
	if Input.is_action_just_released("interact"):
		pass
		
		
	
