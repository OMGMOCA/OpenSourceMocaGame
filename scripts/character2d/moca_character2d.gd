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

@export var damage : int = 20

var hit : bool = false
var sound_hit : AudioStreamPlayer2D = null
signal character_hit(attack_pos : Vector2,damage : int)



func _ready() -> void:
	#获取角色精灵
	sprite_2d = find_child("Sprite2D")
	#角色翻转初始化
	sprite_2d.flip_h = flip
	#获取角色动画树
	animation_tree = find_child("AnimationTree")
	#获取角色音效组件
	sound_jump = find_child("Sound_jump")
	sound_attack = find_child("Sound_attack")
	sound_hit = find_child("Sound_hit")
	#获取角色伤害检测区
	attack_zone = find_child("attackZone")
	#attack_zone_loc用于角色翻转时伤害检测区域的位置调整
	attack_zone_loc = attack_zone.position
	#获取角色攻击时的动画
	attack_sprite = attack_zone.find_child("Sprite2D")
	character_attack_bind()
	character_hit_bind()
	

func _physics_process(delta: float) -> void:
	character_move_control(delta)
	#move_and_slide()为系统函数，用于更新角色的速度等属性
	move_and_slide()
	
	character_health_control()
	
func character_hit_bind() -> void:
	#角色受到攻击
	character_hit.connect(on_character_hit)
	animation_tree.animation_started.connect(on_anima_hit_started)
	
func on_character_hit(is_player : bool,attack_pos : Vector2,_damage : int) -> void:
	if is_dead: return
	
	var dir = attack_pos.x - position.x
	dir = dir / abs(dir)
	if dir > 0:
		flip = false
	elif dir < 0:
		flip = true
	
	velocity = Vector2(-dir * 250,-100)
	hit = true
	#攻击期间应该禁止角色翻转，直到当前动作执行结束
	health -= _damage
	attack_feedback(is_player)
	
func character_attack_bind() -> void:
	animation_tree.animation_started.connect(on_anima_attack_started)
	animation_tree.animation_finished.connect(on_anima_attack_finished)
	attack_zone.body_entered.connect(on_attack_detect)

func on_attack_detect(body: Node2D) -> void:
	#如何在攻击多个敌人时，让命中脚本依次且间隔执行
	for group in attack_groups:
		if body.is_in_group(group):
			#发送消息给被击中的角色
			var is_player = is_in_group("Player")
			body.character_hit.emit(is_player,position,damage)
			#创建被攻击的玩家清单，攻击结束后重置，避免对方承受多次攻击
			break
func attack_feedback(is_player : bool) -> void:
	#仅在攻击者是玩家时执行
	if not is_player: return
	#是否需要将这些功能移至相机脚本?
	#帧冻结
	Engine.time_scale = 0
	await get_tree().create_timer(0.1,true,false,true).timeout
	Engine.time_scale = 1.
	#相机控制
	var current_camera : Camera2D = get_window().get_camera_2d()
	#tween
	var dir : int
	if sprite_2d.flip_h:
		dir = 1
	else:
		dir = -1
	var _offset = current_camera.offset + Vector2(dir * 10,0)
	var _zoom = current_camera.zoom * 1
	var camera_tween : Tween = create_tween()
	
	if current_camera:
		camera_tween.tween_property(current_camera,"offset",current_camera.offset,0.1).from(_offset)
		camera_tween.tween_property(current_camera,"zoom",current_camera.zoom,0.1).from(_zoom)
		
		
func on_anima_hit_started(anima_name : StringName) -> void:
	if anima_name == "hit":
		#如果当前播放动画为hit时执行
		sound_hit.play()
		hit = false
		
func on_anima_attack_started(anima_name : StringName) -> void:
	#尝试合并所有的以动画started事件至一个函数
	if anima_name == "attack01":
		#如果当前播放动画为attack时执行
		sound_attack.play()
		
func on_anima_attack_finished(anima_name : StringName) -> void:
	#尝试合并所有的以动画finished事件至一个函数
	if anima_name == "attack01":
		#如果动画为attack播放结束时执行
		attack_input = false

func character_health_control() -> void:
	#血量反馈
	if health <= 0:
		health = 0
		is_dead = true
		#执行死亡相关功能，例如重置角色
		#如果是玩家死亡仅发消息给gamecontrol
		#如果是其他角色死亡，三秒后销毁
		character_death()
func character_death() -> void:
	await get_tree().create_timer(3,true,false,true).timeout
	queue_free()
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






	
