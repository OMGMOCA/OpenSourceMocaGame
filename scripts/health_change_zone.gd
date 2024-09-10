extends Area2D




@export var target_list : Array = ["player","enemiy","npc"]
@export var health_change_value : int = -100


func on_body_entered(body: Node2D) -> void:
	print(body.name)
	for target in target_list:
		#尝试将名称匹配改为分组匹配
		if body.name == target:
			body.set_health(health_change_value)

func _ready() -> void:
	print("health ready")
	self.body_entered.connect(on_body_entered)
	
