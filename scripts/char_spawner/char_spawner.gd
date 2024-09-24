@tool
extends Node


@export_enum("character", "player") var character_type : String = "character"

@export var speed : float = 100.0
@export var health : int = 100
@export var destroy_wait_time : float = 3.0
@export var flip : bool = false

@export_group("player only")
@export_subgroup("jump")
@export var jump_speed : float = -180 
@export var max_jump_time : float = 0.5  
@export var jump_max_force : float = -17
@export var jump_min_force : float = 0.0


var character : CharSpawner_Character2d = CharSpawner_Character2d.new()

	

func _ready() -> void:
	if Engine.is_editor_hint(): return 
	
	character.animated_sprite_2d = find_child("AnimatedSprite2D")
	character.speed = speed
	character.health= health
	character.destroy_wait_time = destroy_wait_time
	character.flip = flip
	
	character.start("AAA")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return 
	character.process(delta)
