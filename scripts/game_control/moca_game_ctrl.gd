extends Node
class_name MOCAGameControl

#该脚本挂载在名为GameControl的Node节点上，且需要设置玩家的Game Control属性

signal player_death
var reloading : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_death.connect(on_player_death)


func on_player_death() -> void:
	if reloading: return
	reloading = true
	print("player death")
	Engine.time_scale = 0.5
	await get_tree().create_timer(1,true,false,true).timeout
	Engine.time_scale = 1.
	
	get_tree().reload_current_scene()
