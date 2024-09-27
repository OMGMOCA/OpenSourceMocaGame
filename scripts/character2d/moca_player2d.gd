extends MocaCharacter2d


	
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
		
	
