extends Node

@export var player : CharacterBody2D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.character_dead.connect(on_player_dead)
	player.character_destroy.connect(on_player_destroy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_player_dead() -> void:
	print("game control: player dead")
func on_player_destroy() -> void:
	print("game control: player destroy")
	#重新加载
	get_tree().reload_current_scene()
	
