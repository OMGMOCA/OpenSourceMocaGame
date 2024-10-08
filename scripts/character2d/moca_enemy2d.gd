extends MocaCharacter2d



#转向等待时间
var enemy_dir = 1
@export var turn_wait : float = 3.0
var turn_timer : float = 0.0

@export var rush_speed : float = 80.0
@export var normal_speed : float = 50.0
@export var rush_wait : float = 1.0
var rush_timer : float = 0.0

var attack_timer : float = 0
var attack_wait : float = 2.0

var enemy_attack : bool = false

var player : Node2D = null

func _ready() -> void:
	super()
	#设置使用该脚本的角色分组为Player
	add_to_group("Enemies")
	SPEED = normal_speed


func _physics_process(delta: float) -> void:
	super(delta)
	
	
	

	
	if player:
		var dis = player.position.x - position.x
		var dir = dis / abs(dis)

		get_move_input(0)
		rush_timer += delta
		if rush_timer >= rush_wait and abs(dis) > 40:
			get_move_input(dir)
			SPEED = rush_speed
		elif rush_timer >= rush_wait and abs(dis) <= 40:
			if not enemy_attack:
				enemy_attack = true
				get_attack_input(true)
	else:
		turn_timer += delta
		if turn_timer >= turn_wait:
			turn_timer = 0
			enemy_dir *= -1
		get_move_input(enemy_dir)
		
	if enemy_attack:
		attack_timer += delta
		if attack_timer >= attack_wait:
			enemy_attack = false
			attack_timer = 0
		



func on_detect(body: Node2D) -> void:
	if not can_detect: return
	if body != self:
		for group in detect_groups:
			if body.is_in_group(group):
				#发送消息给被击中的角色
				print(name," on_detect - group: ",group)
				player = body
				break
