extends Area2D

#该脚本需要挂载在Area2D节点上使用

@export var attack_groups = ["Player"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body : Node2D) -> void:
	for group in attack_groups:
		if body.is_in_group(group):
			#发送消息给被击中的角色
			body.character_hit.emit(false,position,100)
			break
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
