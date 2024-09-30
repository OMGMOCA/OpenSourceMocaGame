extends MocaCharacter2d

@export var game_control : MOCAGameControl = null

func _ready() -> void:
	super()
	#设置使用该脚本的角色分组为Player
	add_to_group("Player")
	#如何检查场景中是否存在多个Player，并报错
	var nodes = get_tree().get_nodes_in_group("Player")
	if nodes.size() > 1:
		push_error("There are multiple nodes using the moca_player2d.gd script.")
		print_rich("[color=red]There are multiple nodes using the moca_player2d.gd script.[/color]")
	
func _physics_process(delta: float) -> void:
	super(delta)
	get_move_input(Input.get_axis("move_left", "move_right"))
	if Input.is_action_just_pressed("jump"):
		get_jump_input(true)
	if Input.is_action_just_released("jump"):
		get_jump_input(false)
	if Input.is_action_just_pressed("interact"):
		pass
	if Input.is_action_just_released("interact"):
		pass
	
	if Input.is_action_just_pressed("attack1"):
		get_attack_input(true)
	if Input.is_action_just_released("attack1"):
		get_attack_input(false)

func character_death() -> void:
	if game_control:
		game_control.player_death.emit()
