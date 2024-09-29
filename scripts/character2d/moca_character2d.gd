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

var sound_jump : AudioStreamPlayer2D = null
var sound_attack : AudioStreamPlayer2D = null

var attack_input : bool = false
var attack : bool = false
var attack_zone : Area2D = null
var attack_sprite : Sprite2D = null
var attack_zone_loc : Vector2 = Vector2(0,0)
@export var attack_groups = ["Enemies"]

var hit : bool = false
var sound_hit : AudioStreamPlayer2D = null
signal character_hit(attack_pos : Vector2)

func _ready() -> void:
	sprite_2d = find_child("Sprite2D")
	sprite_2d.flip_h = flip
	animation_tree = find_child("AnimationTree")
	sound_jump = find_child("Sound_jump")
	sound_attack = find_child("Sound_attack")
	sound_hit = find_child("Sound_hit")
	attack_zone = find_child("attackZone")
	attack_zone_loc = attack_zone.position
	attack_sprite = attack_zone.find_child("Sprite2D")
	character_attack_bind()
	character_hit_bind()
	

func _physics_process(delta: float) -> void:
	character_move_control(delta)
	move_and_slide()
	
func character_hit_bind() -> void:
	#角色受到攻击
	character_hit.connect(on_character_hit)
	animation_tree.animation_started.connect(on_anima_hit_started)
	
func on_character_hit(attack_pos : Vector2) -> void:
	var dir = attack_pos.x - position.x
	dir = dir / abs(dir)
	if dir > 0:
		flip = false
	elif dir < 0:
		flip = true
	
	velocity = Vector2(-dir * 250,-100)
	hit = true
	
func character_attack_bind() -> void:
	animation_tree.animation_started.connect(on_anima_attack_started)
	animation_tree.animation_finished.connect(on_anima_attack_finished)
	attack_zone.body_entered.connect(on_attack_detect)

func on_attack_detect(body: Node2D) -> void:
	for group in attack_groups:
		if body.is_in_group("Enemies"):
			#发送消息给被击中的角色
			body.character_hit.emit(position)
			attack_feedback()
			#创建被攻击的玩家清单，攻击结束后重置，避免对方承受多次攻击
			break
func attack_feedback() -> void:
	#用于玩家角色的镜头反馈等
	pass
func on_anima_hit_started(anima_name : StringName) -> void:
	if anima_name == "hit":
		sound_hit.play()
		hit = false
		
func on_anima_attack_started(anima_name : StringName) -> void:
	if anima_name == "attack01":
		sound_attack.play()
		
func on_anima_attack_finished(anima_name : StringName) -> void:
	if anima_name == "attack01":
		attack_input = false
	
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
	if flip:
		attack_zone.position = Vector2(-attack_zone_loc.x,attack_zone_loc.y)
	else:
		attack_zone.position = Vector2(attack_zone_loc.x,attack_zone_loc.y)
	attack_sprite.flip_h = flip

	
func get_jump(delta : float) -> void:
	if jump and jump_execute:
		if jump_force_time >= max_jump_force_time or is_on_floor():
			jump = false
			jump_execute = false
			jump_force_time = max_jump_force_time
		var jump_force = lerp(jump_max_force, 0.0, jump_force_time / max_jump_force_time)
		velocity.y += jump_force
	elif jump and not jump_execute:
		if jump_wait_time >= max_jump_wait_time:
			jump = false
			jump_execute = false
		elif is_on_floor():
			jump_execute = true
			sound_jump.play()
			velocity.y = jump_inital_speed
			jump_force_time = 0
	jump_force_time += delta	
	jump_wait_time += delta
	jump_execute = jump


func get_move_input(dir : float) -> void:
	direction = dir

func get_jump_input(input : bool) -> void:
	if input:
		jump = true
		jump_wait_time = 0
	else:
		jump = false

func get_attack_input(input : bool) -> void:
	#攻击动画也需要像跳跃那样的输入暂存功能
	if input:
		attack_input = true






	
