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
		
func attack_feedback() -> void:
	super()
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
