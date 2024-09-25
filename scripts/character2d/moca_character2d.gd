extends CharacterBody2D
class_name MocaCharacter2d

@export var SPEED = 100.0
@export var health : int = 100
@export var destroy_wait_time : int = 3
@export var flip : bool = false

var jump : bool = false #跳跃输入
var jump_execute : bool = false
@export var jump_inital_speed = -180
var jump_wait_time : float = 0.0
var max_jump_wait_time : float = 0.1
var jump_force_time : float = 0.0
@export var max_jump_force_time : float = 0.5
@export var jump_max_force : float = -17

var sprite_2d : Sprite2D = null
var animation_tree : AnimationTree = null
var is_dead : bool = false
var direction : float = 0


func _ready() -> void:
	sprite_2d = find_child("Sprite2D")
	sprite_2d.flip_h = flip
	animation_tree = find_child("AnimationTree")
	

func _physics_process(delta: float) -> void:

	get_move_input(Input.get_axis("move_left", "move_right"))
	if Input.is_action_just_pressed("jump"):
		get_jump_input(true)
	if Input.is_action_just_released("jump"):
		get_jump_input(false)
	

	
	character_move_control(delta)
	move_and_slide()
	

	
func character_move_control(delta: float) -> void:
	#重力控制
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not is_dead:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			

		animation_tree.set("parameters/walk/blend_position",direction)
		
		

		get_jump(delta)
		character_flip(direction)
	else:
		velocity.x = 0

func character_flip(dir : float) -> void:
	if dir > 0:
		flip = false
	elif dir < 0:
		flip = true
		
	sprite_2d.flip_h = flip
	
func get_move_input(dir : float) -> void:
	direction = dir

func get_jump_input(input : bool) -> void:
	if input:
		jump = true
		jump_wait_time = 0
	else:
		jump = false
	
func get_jump(delta : float) -> void:
	
	if not jump_execute:
		jump_wait_time += delta
		if jump_wait_time >= max_jump_wait_time:
			jump = false
		elif is_on_floor():
			jump_execute = true
			velocity.y = jump_inital_speed
			jump_force_time = 0

	if jump and jump_execute:
		jump_force_time += delta
		if jump_force_time >= max_jump_force_time:
			jump = false
			jump_execute = false
			jump_force_time = max_jump_force_time
		var jump_force = lerp(jump_max_force, 0.0, jump_force_time / max_jump_force_time)
		velocity.y += jump_force
	elif not jump:
		jump_execute = jump


		






	
