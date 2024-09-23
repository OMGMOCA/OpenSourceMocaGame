@tool
extends Node2D
class_name aaaaa


@export var begin : bool = false:
	set(arg1):
		print("CharSpawner_Character2d _init()")
		# 创建子节点
		var animated_sprite = AnimatedSprite2D.new()
		add_child(animated_sprite)
		animated_sprite.name = "AnimatedSprite2D"
		animated_sprite.owner = self
	
		
		var p = animated_sprite.get_parent()
		print("p.name: ",p.name)
	get:
		return begin
		
func _ready() -> void:
	print("_ready()")
	var animated_sprite = AnimatedSprite2D.new()
	add_child(animated_sprite)
	animated_sprite.name = "AnimatedSprite2D"
	animated_sprite.owner = self
