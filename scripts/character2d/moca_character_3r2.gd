extends MocaCharacter2d

var sub_viewport : SubViewport = null
@export var reset_frame_rate : bool = false
@export var frame_rate : int = 12

var timer : float = 0.0

func _ready() -> void:
	super()
	#抽帧
	sub_viewport = find_child("SubViewport")
	if reset_frame_rate:
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	else:
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS



func _physics_process(delta: float) -> void:
	super(delta)
	#抽帧
	if reset_frame_rate:
		timer += delta
		var frame_interval = 1.0 / frame_rate
		if timer >= frame_interval:
			#求余，复位timer
			timer = fmod(timer,frame_interval)
			sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
